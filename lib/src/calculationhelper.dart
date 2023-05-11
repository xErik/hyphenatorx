import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'pattern.dart';

class CalculationHelper {
  final _startEndMarker = '.';
  final List<Pattern> _patterns;
  final int _minLetterCount;
  final int _minWordLength;
  final String hyphenateSymbol;
  final Map<String, String> cacheHyphendWords = {};
  final Map<String, String> cacheNonHyphendWords = {};
  final Map<String, List<String>> cacheHyphenateWordToList = {};
  final Map<String, List<String>> cacheNonHyphenateWordToList = {};

  // final Map<String, List<int>> _cacheGenerateLevelsForWord = {};
  // final Map<String, List<int>> _cacheHyphenatedMaskFromLevels = {};
  // final Map<String, List<int>> _cacheCorrectHyphenationMask = {};

  CalculationHelper(this._patterns, this._minLetterCount, this._minWordLength,
      this.hyphenateSymbol);

  void logCache() {
    if (kDebugMode) {
      log("cacheHyphendWords: ${cacheHyphendWords.entries.length}");
    }
  }

  List<int> generateLevelsForWord(String word) {
    // if (_cacheGenerateLevelsForWord.containsKey(word)) {
    //   return _cacheGenerateLevelsForWord[word]!;
    // }

    final wordString = '$_startEndMarker$word$_startEndMarker';

    final levels = List.filled(wordString.length, 0);

    for (int i = 0; i < wordString.length - 2; ++i) {
      int patternIndex = 0;

      for (int count = 1; count <= wordString.length - i; ++count) {
        var patternFromWord =
            Pattern.patternOnly(wordString.substring(i, i + count));

        if (patternFromWord.compareTo(_patterns[patternIndex]) < 0) continue;

        patternIndex = _patterns.indexWhere(
          (pattern) => pattern.compareTo(patternFromWord) > 0,
          patternIndex,
        );

        if (patternIndex == -1) break;

        if (patternFromWord.compareTo(_patterns[patternIndex]) >= 0)
          for (int levelIndex = 0;
              levelIndex < _patterns[patternIndex].levelsCount - 1;
              ++levelIndex) {
            int level = _patterns[patternIndex].levelByIndex(levelIndex);

            if (level > levels[i + levelIndex]) levels[i + levelIndex] = level;
          }
      }
    }

    // _cacheGenerateLevelsForWord[word] = levels;

    return levels;
  }

  List<int> hyphenatedMaskFromLevels(List<int> levels) {
    // final key = levels.toString();
    // if (_cacheHyphenatedMaskFromLevels.containsKey(key)) {
    //   return _cacheHyphenatedMaskFromLevels[key]!;
    // }

    final int length = levels.length - 2;

    final hyphenationMask = List<int>.filled(length, 0);
    hyphenationMask[0] = 0;

    for (int i = 1; i < length; i++) {
      if (levels[i + 1] % 2 != 0) hyphenationMask[i] = 1;
    }

    // _cacheHyphenatedMaskFromLevels[key] = hyphenationMask;

    return hyphenationMask;
  }

  List<int> correctHyphenationMask(List<int> mask) {
    // final key = mask.toString();
    // if (_cacheCorrectHyphenationMask.containsKey(key)) {
    //   return _cacheCorrectHyphenationMask[key]!;
    // }

    if (mask.length > _minLetterCount) {
      for (int i = 0; i < _minLetterCount; i++) {
        mask[i] = 0;
      }

      final correctionLength = _minLetterCount > 0 ? _minLetterCount - 1 : 0;

      for (int i = mask.length - correctionLength; i < mask.length; i++) {
        mask[i] = 0;
      }
    } else {
      for (int i = 0; i < mask.length; i++) {
        mask[i] = 0;
      }
    }

    // _cacheCorrectHyphenationMask[key] = mask;

    return mask;
  }

  String hyphenateByMask(String word, List<int>? mask) {
    var result = StringBuffer();
    for (int i = 0; i < word.length; i++) {
      if (mask![i] > 0) result.write(hyphenateSymbol);
      result.write(word[i]);
    }
    return result.toString();
  }

  List<String> hyphenateByMaskToList(String word, List<int>? mask) {
    StringBuffer currentSyllable = StringBuffer();
    List<String> returnList = <String>[];

    for (int i = 0; i < word.length; i++) {
      if (mask![i] > 0) {
        returnList.add(currentSyllable.toString());
        currentSyllable.clear();
      }
      currentSyllable.write(word[i]);
    }

    returnList.add(currentSyllable.toString());
    return returnList;
  }

  bool isNotNeedHyphenate(String input) => input.length < _minWordLength;
}
