import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/person/presentation/bloc/person_list_cubit/person_list_cubit.dart';
import 'features/person/presentation/pages/person_screen.dart';
import 'locator_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const RickAndMortyApp());
}

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rick and Morty',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: false,
      scaffoldBackgroundColor: const Color(0xff272b33),
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        surface: Color(0xff3c3e44),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff202329),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
      ),
    ),
    home: BlocProvider(
      create: (_) => sl<PersonListCubit>()..loadNext(),
      child: const PersonScreen(),
    ),
  );
}
