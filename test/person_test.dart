import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panel_13_arc/core/error/exceptions.dart';
import 'package:panel_13_arc/core/error/failures.dart';
import 'package:panel_13_arc/core/network/network_info.dart';
import 'package:panel_13_arc/features/person/data/models/person_model.dart';
import 'package:panel_13_arc/features/person/data/datasources/person_local_data_source.dart';
import 'package:panel_13_arc/features/person/data/datasources/person_remote_data_source.dart';
import 'package:panel_13_arc/features/person/data/repositories/person_repository_impl.dart';
import 'package:panel_13_arc/features/person/domain/entities/person_entity.dart';
import 'package:panel_13_arc/features/person/domain/repositories/person_repository.dart';
import 'package:panel_13_arc/features/person/domain/usecases/get_all_persons.dart';
import 'package:panel_13_arc/features/person/domain/usecases/search_person.dart';
import 'package:panel_13_arc/features/person/presentation/bloc/person_list_cubit/person_list_cubit.dart';
import 'package:panel_13_arc/features/person/presentation/bloc/person_list_cubit/person_list_state.dart';
import 'package:panel_13_arc/features/person/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:panel_13_arc/features/person/presentation/bloc/search_bloc/search_event.dart';
import 'package:panel_13_arc/features/person/presentation/bloc/search_bloc/search_state.dart';

Map<String, dynamic> character(int id) => {
  'id': id,
  'name': 'Character $id',
  'status': 'Alive',
  'species': 'Human',
  'gender': 'Male',
  'image': 'https://example.com/$id.jpeg',
  'origin': {'name': 'Earth'},
  'location': {'name': 'Citadel'},
};
PersonPageModel page(List<int> ids, int? next) => PersonPageModel(
  persons: ids.map((id) => PersonModel.fromJson(character(id))).toList(),
  nextPage: next,
);

class Network implements NetworkInfo {
  Network(this.online);
  bool online;
  @override
  Future<bool> get isConnected async => online;
}

class Remote implements PersonRemoteDataSource {
  int calls = 0;
  bool fails = false;
  @override
  Future<PersonPageModel> fetch(int p, {String query = ''}) async {
    calls++;
    if (fails) {
      throw const ServerException('Server unavailable');
    }
    return page([p], p < 2 ? p + 1 : null);
  }
}

class Repository implements PersonRepository {
  int calls = 0;
  bool failNext = false;
  final Map<String, Completer<PersonPage>> pending = {};
  @override
  Future<PersonPage> getAllPersons(int p) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (failNext) {
      failNext = false;
      throw const Failure('Retry');
    }
    return page(p == 1 ? [1, 2] : [2, 3], p == 1 ? 2 : null);
  }

  @override
  Future<PersonPage> searchPerson(String q, int p) {
    calls++;
    return pending.putIfAbsent(q, () => Completer<PersonPage>()).future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('character JSON round trip, nullable fields and value equality', () {
    final model = PersonModel.fromJson(character(1));
    expect(PersonModel.fromJson(model.toJson()), model);
    expect(PersonModel.fromJson({'id': 2, 'name': 'Test'}).origin, 'unknown');
    expect(() => PersonModel.fromJson({'name': 'Bad'}), throwsFormatException);
    expect(PersonPageModel.fromJson(page([1], 2).toJson()).nextPage, 2);
  });
  test(
    'remote encodes query, parses pagination, handles 404 and malformed JSON',
    () async {
      final source = PersonRemoteDataSourceImpl(
        MockClient((request) async {
          expect(request.url.queryParameters['name'], 'rick & morty');
          expect(request.url.queryParameters['page'], '2');
          return http.Response(jsonEncode(page([1], 3).toJson()), 200);
        }),
      );
      expect((await source.fetch(2, query: 'rick & morty')).nextPage, 3);
      expect(
        (await PersonRemoteDataSourceImpl(
          MockClient((_) async => http.Response('{}', 404)),
        ).fetch(1, query: 'none')).persons,
        isEmpty,
      );
      await expectLater(
        PersonRemoteDataSourceImpl(
          MockClient((_) async => http.Response('bad', 200)),
        ).fetch(1),
        throwsA(isA<ServerException>()),
      );
      await expectLater(
        PersonRemoteDataSourceImpl(
          MockClient((_) async => http.Response('{}', 503)),
        ).fetch(1),
        throwsA(isA<ServerException>()),
      );
    },
  );
  test('remote rate limiting gives a clear retry message', () async {
    final source = PersonRemoteDataSourceImpl(
      MockClient((_) async => http.Response('{}', 429)),
    );
    await expectLater(
      source.fetch(1),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          contains('wait a moment'),
        ),
      ),
    );
  });
  test(
    'repository caches each page, falls back offline and on server failure',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final local = PersonLocalDataSourceImpl(prefs);
      final network = Network(true);
      final remote = Remote();
      final repo = PersonRepositoryImpl(
        remote: remote,
        local: local,
        network: network,
      );
      await repo.getAllPersons(1);
      await repo.getAllPersons(2);
      network.online = false;
      expect((await repo.getAllPersons(2)).isCached, true);
      expect(remote.calls, 2);
      await expectLater(repo.getAllPersons(3), throwsA(isA<Failure>()));
      await expectLater(repo.searchPerson('rick', 1), throwsA(isA<Failure>()));
      network.online = true;
      remote.fails = true;
      expect((await repo.getAllPersons(1)).isCached, true);
      await prefs.setString('characters_v1_page_1', 'invalid');
      await expectLater(local.read(1), throwsA(isA<CacheException>()));
    },
  );
  test('Cubit prevents concurrent requests, preserves data on failure, retries and stops at end', () async {
    final repo = Repository();
    final cubit = PersonListCubit(GetAllPersons(repo));
    final first = cubit.loadNext();
    await cubit.loadNext();
    await first;
    expect(repo.calls, 1);
    expect(cubit.state.persons.length, 2);
    repo.failNext = true;
    await cubit.loadNext();
    expect(cubit.state.persons.length, 2);
    expect(cubit.state.error, 'Retry');
    await cubit.loadNext();
    expect(cubit.state.persons.map((p) => p.id), [1, 2, 3]);
    expect(cubit.state.nextPage, isNull);
    await cubit.loadNext();
    expect(repo.calls, 3);
    expect(cubit.state.status, PersonListStatus.loaded);
    await cubit.close();
  });
  test(
    'search debounce skips obsolete queries and ignores stale responses',
    () async {
      final repo = Repository();
      final bloc = SearchBloc(
        SearchPerson(repo),
        debounce: const Duration(milliseconds: 15),
      );
      bloc.add(const SearchQueryChanged('r'));
      bloc.add(const SearchQueryChanged('rick'));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(repo.calls, 1);
      bloc.add(const SearchQueryChanged('morty'));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      repo.pending['morty']!.complete(page([2], null));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      repo.pending['rick']!.complete(page([1], null));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(bloc.state.query, 'morty');
      expect(bloc.state.persons.single.id, 2);
      bloc.add(const SearchQueryChanged(''));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(bloc.state.status, SearchStatus.initial);
      await bloc.close();
    },
  );
  test('search empty and error states support retry', () async {
    final repo = Repository();
    final bloc = SearchBloc(SearchPerson(repo), debounce: Duration.zero);
    bloc.add(const SearchQueryChanged('empty'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    repo.pending['empty']!.complete(page([], null));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(bloc.state.status, SearchStatus.empty);
    bloc.add(const SearchQueryChanged('error'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    repo.pending['error']!.completeError(const Failure('Offline'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    expect(bloc.state.status, SearchStatus.error);
    expect(bloc.state.error, 'Offline');
    await bloc.close();
  });
}
