import 'package:hyphenatorx/src/calculationhelper.dart';

import 'languages/languageconfig.dart';
import 'src/pattern.dart';

class Hyphenator {
  final List<Pattern> _patterns = [];
  final Map<String, List<int>> _exceptions = {};
  final String hyphenateSymbol;
  final int minWordLength;
  final int minLetterCount;
  late final CalculationHelper calc;

  static Future<Hyphenator> load(
    Language lang, {
    hyphenateSymbol = '\u{00AD}',
    minWordLength = 5,
    minLetterCount = 3,
  }) async {
    return Hyphenator(
      await LanguageConfig.load(lang),
      hyphenateSymbol: hyphenateSymbol,
      minWordLength: minWordLength,
      minLetterCount: minLetterCount,
    );
  }

  Hyphenator(
    LanguageConfig config, {
    this.hyphenateSymbol = '\u{00AD}',
    this.minWordLength = 5,
    this.minLetterCount = 3,
  }) {
    assert(minWordLength > 0);

    _patterns.addAll(config.data['pattern']
        .map<Pattern>((pattern) => Pattern(
            pattern['result'] as String, List<int>.from(pattern['levels'])))
        .toList()
      ..sort());

    _exceptions.addEntries(
      (config.data['exception'] as Map<String, dynamic>)
          .entries
          .map((entry) => MapEntry(entry.key, List<int>.from(entry.value))),
    );

    calc = CalculationHelper(
        _patterns, minLetterCount, minWordLength, hyphenateSymbol);
  }

  List<String> get cachedHyphendWords => calc.cacheHyphendWords.values.toList();
  List<String> get cachedNonHyphendWords =>
      calc.cacheNonHyphendWords.values.toList();

  /// Hyphenates a string with spaces.
  String hyphenate(String text) {
    var currentWord = StringBuffer();
    var result = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final c = text[i];

      // is letter?
      if (!(c == c.toLowerCase() && c == c.toUpperCase())) {
        currentWord.write(c);
      } else {
        if (currentWord.length > 0) {
          result.write(hyphenateWord(currentWord.toString()));
          currentWord.clear();
        }
        result.write(c);
      }
    }

    result.write(hyphenateWord(currentWord.toString()));

    calc.logCache();

    return result.toString();
  }

  /// Hyphenates a single word.
  String hyphenateWord(String inputWord) {
    if (calc.isNotNeedHyphenate(inputWord)) return inputWord;

    if (calc.cacheHyphendWords.containsKey(inputWord)) {
      return calc.cacheHyphendWords[inputWord]!;
    }
    if (calc.cacheNonHyphendWords.containsKey(inputWord)) {
      return calc.cacheNonHyphendWords[inputWord]!;
    }

    final word = inputWord.toLowerCase();

    List<int>? hyphenationMask;

    if (_exceptions.containsKey(word))
      hyphenationMask = _exceptions[word];
    else {
      final levels = calc.generateLevelsForWord(word);
      hyphenationMask = calc.hyphenatedMaskFromLevels(levels);
      calc.correctHyphenationMask(hyphenationMask);
    }

    final result = calc.hyphenateByMask(inputWord, hyphenationMask);
    if (result == inputWord) {
      calc.cacheNonHyphendWords[inputWord] = result;
    } else {
      calc.cacheHyphendWords[inputWord] = result;
    }
    return result;
  }

  /// Hyphenates a string and returns a list of
  /// valid hyphenations.
  List<String> hyphenateWordToList(String inputWord) {
    if (calc.isNotNeedHyphenate(inputWord)) return <String>[inputWord];

    if (calc.cacheHyphenateWordToList.containsKey(inputWord)) {
      return calc.cacheHyphenateWordToList[inputWord]!;
    }

    if (calc.cacheNonHyphenateWordToList.containsKey(inputWord)) {
      return calc.cacheNonHyphenateWordToList[inputWord]!;
    }

    final word = inputWord.toLowerCase();

    List<int>? hyphenationMask;

    if (_exceptions.containsKey(word))
      hyphenationMask = _exceptions[word];
    else {
      final levels = calc.generateLevelsForWord(word);
      hyphenationMask = calc.hyphenatedMaskFromLevels(levels);
      hyphenationMask = calc.correctHyphenationMask(hyphenationMask);
    }

    final result = calc.hyphenateByMaskToList(inputWord, hyphenationMask);
    if (result == inputWord) {
      calc.cacheNonHyphenateWordToList[inputWord] = result;
    } else {
      calc.cacheHyphenateWordToList[inputWord] = result;
    }
    return result;
    // return calc.hyphenateByMaskToList(inputWord, hyphenationMask);
  }
}
