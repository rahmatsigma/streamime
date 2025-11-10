import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.dark));

  void toggleTheme(bool isDark) {
    final newThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeState(newThemeMode));
  }
}