import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState(ThemeMode.light)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null && !isClosed) {
      emit(ThemeState(ThemeMode.values[themeIndex]));
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(ThemeState(mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  void toggleTheme() {
    final newMode = state.mode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setTheme(newMode);
  }
}

class ThemeState extends Equatable {
  final ThemeMode mode;

  const ThemeState(this.mode);

  @override
  List<Object?> get props => [mode];
}
