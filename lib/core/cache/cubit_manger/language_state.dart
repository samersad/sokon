import 'package:flutter/material.dart';

abstract class LanguageState {
  final Locale locale;
  const LanguageState(this.locale);
}

class LanguageEnglish extends LanguageState {
  const LanguageEnglish() : super(const Locale('en'));
}

class LanguageArabic extends LanguageState {
  const LanguageArabic() : super(const Locale('ar'));
}
