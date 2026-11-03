import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/person_repository.dart';
import '../datasources/person_local_data_source.dart';
import '../datasources/person_remote_data_source.dart';

class PersonRepositoryImpl implements PersonRepository {
  PersonRepositoryImpl({
    required this.remote,
    required this.local,
    required this.network,
  });
  final PersonRemoteDataSource remote;
  final PersonLocalDataSource local;
  final NetworkInfo network;
  @override
  Future<PersonPage> getAllPersons(int page) async {
    String message =
        'No internet connection and no saved characters. Connect and retry.';
    try {
      if (await network.isConnected) {
        final result = await remote.fetch(page);
        try {
          await local.cache(page, result);
        } catch (_) {
          /* A storage failure must not hide fresh data. */
        }
        return result;
      }
    } on ServerException catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Unable to load characters. Please retry.';
    }
    try {
      return await local.read(page);
    } catch (_) {
      throw Failure(message);
    }
  }

  @override
  Future<PersonPage> searchPerson(String query, int page) async {
    try {
      if (!await network.isConnected) {
        throw const Failure('Search needs an internet connection.');
      }
      return await remote.fetch(page, query: query);
    } on Failure {
      rethrow;
    } on ServerException catch (e) {
      throw Failure(e.message);
    } catch (_) {
      throw const Failure('Unable to search. Please retry.');
    }
  }
}
