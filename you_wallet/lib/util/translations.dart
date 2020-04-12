import 'package:youwallet/util/locale_util.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show  rootBundle;

/// Class for Translate
///
/// For example:
///
/// import 'package:workout/translations.dart';
///
/// ```dart
/// For TextField content
/// Translations.of(context).text("home_page_title");
/// ```
///
/// ```dart
/// For speak string
/// Note: Tts will speak english if currentLanguage[# Tts's parameter] can't support
///
/// Translations.of(context).speakText("home_page_title");
/// ```
///
/// "home_page_title" is the key for text value
///
///
/// 系统提供了LocalizationsDelegate类帮助我们监听系统语言的切换，
/// 所以我们可以继承LocalizationsDelegate类监听语言切换，
/// 并在切换时加载不同的json文件，来获取不同的语言文案。
/// 这里我们的translations工具类就是利用这样的原理来加载不同的语言文案：
/// 我们看到有两个继承自LocalizationsDelegate类的代理类，
/// SpecificLocalizationDelegate类是提供一种让我们强制指定一种位置的方式，
/// 通过改变传进来的local来达到从新load新json的方式。
/// 如果你没有这种需求，可以只关心TranslationsDelegate这种默认方式。
class Translations {
  Translations(Locale locale) {
    this.locale = locale;
    _localizedValues = null;
  }

  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;
  static Map<dynamic, dynamic> _localizedValuesEn; // English map

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }


  String text(String key) {
    try {
      String value = _localizedValues[key];
      if(value == null || value.isEmpty) {
        return englishText(key);
      } else {
        return value;
      }
    } catch (e) {
      return englishText(key);
    }
  }

  String englishText(String key) {
    return _localizedValuesEn[key] ?? '** $key not found';
  }

  static Future<Translations> load(Locale locale) async {
    Translations translations = new Translations(locale);
    String jsonContent = await rootBundle.loadString("locale/i18n_${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    String enJsonContent = await rootBundle.loadString("locale/i18n_en.json");
    _localizedValuesEn = json.decode(enJsonContent);
    return translations;
  }

  get currentLanguage => locale.languageCode;
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  // Support languages
  @override
  bool isSupported(Locale locale) {
    localeUtil.languageCode = locale.languageCode;
    return localeUtil.supportedLanguages.contains(locale.languageCode);
  }

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(TranslationsDelegate old) => true;
}

// Delegate strong init a Translations instance when language was changed
class SpecificLocalizationDelegate extends LocalizationsDelegate<Translations> {
  final Locale overriddenLocale;

  const SpecificLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<Translations> load(Locale locale) => Translations.load(overriddenLocale);

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => true;
}