import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'features/person/data/datasources/person_local_data_source.dart';
import 'features/person/data/datasources/person_remote_data_source.dart';
import 'features/person/data/repositories/person_repository_impl.dart';
import 'features/person/domain/repositories/person_repository.dart';
import 'features/person/domain/usecases/get_all_persons.dart';
import 'features/person/domain/usecases/search_person.dart';
import 'features/person/presentation/bloc/person_list_cubit/person_list_cubit.dart';
import 'features/person/presentation/bloc/search_bloc/search_bloc.dart';

final sl = GetIt.instance;
Future<void> initDependencies() async {
  sl.registerLazySingleton<http.Client>(
    () => http.Client(),
    dispose: (client) => client.close(),
  );
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<PersonRemoteDataSource>(
    () => PersonRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PersonLocalDataSource>(
    () => PersonLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PersonRepository>(
    () => PersonRepositoryImpl(remote: sl(), local: sl(), network: sl()),
  );
  sl.registerLazySingleton(() => GetAllPersons(sl()));
  sl.registerLazySingleton(() => SearchPerson(sl()));
  sl.registerFactory(() => PersonListCubit(sl()));
  sl.registerFactory(() => SearchBloc(sl()));
}
