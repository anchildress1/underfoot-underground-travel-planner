import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/screens/home_screen.dart';

class UnderfootApp extends StatelessWidget {
  const UnderfootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Underfoot',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.mode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
