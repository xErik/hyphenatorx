import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'pattern.dart';

class CalculationHelper {
  final _startEndMarker = '.';
  final List<Pattern> _patterns;
  final Map<String, List<int>> _exceptions;
  final int _minLetterCount;
  final int _minWordLength;
  final String symbol;
  final Map<String, String> cacheHyphendWords = {};
  final Map<String, String> cacheNonHyphendWords = {};
  final Map<String, List<String>> cacheHyphenateWordToList = {};
  final Map<String, List<String>> cacheNonHyphenateWordToList = {};

  // final Map<String, List<int>> _cacheGenerateLevelsForWord = {};
  // final Map<String, List<int>> _cacheHyphenatedMaskFromLevels = {};
  // final Map<String, List<int>> _cacheCorrectHyphenationMask = {};

  CalculationHelper(this._patterns, this._exceptions, this._minLetterCount,
      this._minWordLength, this.symbol);

  void logCache() {
    if (kDebugMode) {
      log("cacheHyphendWords: ${cacheHyphendWords.entries.length}");
    }
  }

  String hyphenate(final String word) {
    List<int> hyphenationMask = _generateHyphenationMask(word);
    return _hyphenateByMask(word, hyphenationMask);
  }

  List<String> hyphenateToList(final String word) {
    List<int> hyphenationMask = _generateHyphenationMask(word);
    return _hyphenateByMaskToList(word, hyphenationMask);
  }

  // -------------------------------------------------------------------------
  // Generate mask
  // -------------------------------------------------------------------------

  List<int> _generateHyphenationMask(final String word) {
    List<int> hyphenationMask;

    final wordForLookup = word.toLowerCase();

    if (_exceptions.containsKey(wordForLookup))
      hyphenationMask = _exceptions[wordForLookup]!;
    else {
      final levels = _generateLevelsForWord(wordForLookup);
      hyphenationMask = _hyphenatedMaskFromLevels(levels);
      hyphenationMask = _correctHyphenationMask(hyphenationMask);
    }

    return hyphenationMask;
  }

  // -------------------------------------------------------------------------
  // Hyphenate by mask
  // -------------------------------------------------------------------------

  String _hyphenateByMask(final String word, final List<int> mask) {
    final result = StringBuffer();

    for (int i = 0; i < word.length; i++) {
      if (mask[i] > 0) {
        result.write(symbol);
      }
      result.write(word[i]);
    }

    return result.toString();
  }

  List<String> _hyphenateByMaskToList(final String word, final List<int> mask) {
    final StringBuffer currentSyllable = StringBuffer();
    final List<String> list = <String>[];

    for (int i = 0; i < word.length; i++) {
      if (mask[i] > 0) {
        list.add(currentSyllable.toString());
        currentSyllable.clear();
      }
      currentSyllable.write(word[i]);
    }

    list.add(currentSyllable.toString());

    return list;
  }

  // -------------------------------------------------------------------------
  // Generate levels
  // -------------------------------------------------------------------------

  List<int> _generateLevelsForWord(final String word) {
    // if (_cacheGenerateLevelsForWord.containsKey(word)) {
    //   return _cacheGenerateLevelsForWord[word]!;
    // }

    final wordString = '$_startEndMarker$word$_startEndMarker';

    final levels = List.filled(wordString.length, 0, growable: false);

    for (int i = 0; i < wordString.length - 2; ++i) {
      int patternIndex = 0;

      for (int count = 1; count <= wordString.length - i; ++count) {
        var patternFromWord =
            Pattern.patternOnly(wordString.substring(i, i + count));

        if (patternFromWord.compareTo(_patterns[patternIndex]) < 0) continue;

        patternIndex = _patterns.indexWhere(
            (pattern) => pattern.compareTo(patternFromWord) > 0, patternIndex);

        if (patternIndex == -1) {
          break;
        }

        if (patternFromWord.compareTo(_patterns[patternIndex]) >= 0)
          for (int levelIndex = 0;
              levelIndex < _patterns[patternIndex].levelsCount - 1;
              ++levelIndex) {
            final int level = _patterns[patternIndex].levelByIndex(levelIndex);

            if (level > levels[i + levelIndex]) {
              levels[i + levelIndex] = level;
            }
          }
      }
    }

    // _cacheGenerateLevelsForWord[word] = levels;

    return levels;
  }

  List<int> _hyphenatedMaskFromLevels(final List<int> levels) {
    // final key = levels.toString();
    // if (_cacheHyphenatedMaskFromLevels.containsKey(key)) {
    //   return _cacheHyphenatedMaskFromLevels[key]!;
    // }

    final int length = levels.length - 2;

    final hyphenationMask = List<int>.filled(length, 0, growable: false);
    // hyphenationMask[0] = 0;

    for (int i = 1; i < length; i++) {
      if (levels[i + 1] % 2 != 0) hyphenationMask[i] = 1;
    }

    // _cacheHyphenatedMaskFromLevels[key] = hyphenationMask;

    return hyphenationMask;
  }

  /// Well returns the modified list itself.
  List<int> _correctHyphenationMask(final List<int> mask) {
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

  bool isNotNeedHyphenate(final String input) => input.length < _minWordLength;
}
