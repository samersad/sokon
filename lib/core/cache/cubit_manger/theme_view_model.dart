import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokon/core/cache/shared_prefs_helper.dart';

abstract class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

class ThemeLight extends ThemeState {
  const ThemeLight() : super(ThemeMode.light);
}

class ThemeDark extends ThemeState {
  const ThemeDark() : super(ThemeMode.dark);
}

class ThemeViewModel extends Cubit<ThemeState> {
  static const _key = 'is_dark_mode';

  ThemeViewModel() : super(_load());

  static ThemeState _load() {
    final isDark = SharedPrefsHelper.getData(key: _key);
    return (isDark == true) ? const ThemeDark() : const ThemeLight();
  }

  bool get isDark => state is ThemeDark;

  void toggleTheme() => setDark(dark: !isDark);

  void setDark({required bool dark}) {
    emit(dark ? const ThemeDark() : const ThemeLight());
    SharedPrefsHelper.saveData(key: _key, value: dark);
  }
}
