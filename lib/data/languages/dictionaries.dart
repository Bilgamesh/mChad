import 'package:flutter/material.dart';
import 'package:mchad/data/languages/dictionaries/english.dart';
import 'package:mchad/data/languages/dictionaries/polish.dart';
import 'package:mchad/data/notifiers.dart';

class Dictionaries {
  static final all = [englishDictionary, polishDictionary];
  static const locales = [Locale('en'), Locale('pl')];
  static const codes = ['en_US', 'pl_PL'];

  static int getLanguageIndex(String code) {
    var index = codes.indexOf(code);
    if (index == -1) return 0;
    return index;
  }

  static String resolveLanguageCode(String code) {
    var selectedDictionary = languageNotifier.value;
    switch (code) {
      case 'en_US':
        return selectedDictionary.english;
      case 'pl_PL':
        return selectedDictionary.polish;
      default:
        throw 'Invalid language code';
    }
  }

  static List<String> get languageNames {
    List<String> names = [];
    for (var dictionary in all) {
      names.add(resolveLanguageCode(dictionary.code));
    }
    return names;
  }
}
