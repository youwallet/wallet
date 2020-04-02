import 'package:flutter/material.dart';

typedef void LocaleChangeCallback(Locale locale);

// 工具类，用来处理app国际化的资源翻译问题
class LocaleUtil {

  // Support languages list
  final List<String> supportedLanguages = ['en','zh', 'ja'];

  // Support Locales list
  Iterable<Locale> supportedLocales() => supportedLanguages.map<Locale>((lang) => new Locale(lang, ''));

  // Callback for manual locale changed
  LocaleChangeCallback onLocaleChanged;

  Locale locale;
  String languageCode;

  static final LocaleUtil _localeUtil = new LocaleUtil._internal();

  factory LocaleUtil() {
    return _localeUtil;
  }

  LocaleUtil._internal();

  /// 获取当前系统语言
  String getLanguageCode() {
    if(languageCode == null) {
      return "en";
    }
    return languageCode;
  }
}

LocaleUtil localeUtil = new LocaleUtil();