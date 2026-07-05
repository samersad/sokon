import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokon/core/cache/shared_prefs_helper.dart';
import 'language_state.dart';

class LanguageViewModel extends Cubit<LanguageState> {
  static const _key = 'app_language';

  LanguageViewModel() : super(_load());

  static LanguageState _load() {
    final langCode = SharedPrefsHelper.getData(key: _key);
    if (langCode == 'ar') {
      return const LanguageArabic();
    }
    return const LanguageEnglish();
  }

  String get appLanguage => state.locale.languageCode;

  void changeLanguage(String newLanguage) {
    if (appLanguage == newLanguage) return;

    if (newLanguage == 'ar') {
      emit(const LanguageArabic());
    } else {
      emit(const LanguageEnglish());
    }
    SharedPrefsHelper.saveData(key: _key, value: newLanguage);
  }
}
