import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocale {
  final Locale locale;

  AppLocale(this.locale);

  static AppLocale? of(BuildContext context) {
    return Localizations.of(context, AppLocale);
  }

  static const LocalizationsDelegate<AppLocale> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localized;

  Future<bool> loadLangs() async {
    String jsonString =
        await rootBundle.loadString('assets/langs/${locale.languageCode}.json');

    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    _localized = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String? translate(String key) {
    return _localized[key];
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocale> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocale> load(Locale locale) async {
    AppLocale localizations = AppLocale(locale);
    await localizations.loadLangs();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
