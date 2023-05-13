import 'package:hyphenatorx/src/calculationhelper.dart';

import 'languages/languageconfig.dart';
import 'src/pattern.dart';

/// Wrapper class hyphenating text.
class Hyphenator {
  late final CalculationHelper calc;

  static Language _getLanguageEnum(String lang) {
    Language l;
    final name = 'language_' + lang;
    try {
      l = Language.values.firstWhere((l) => l.name == name);
    } catch (e) {
      throw 'Language not found: $lang ($name). Try: ${languageAbbr()}';
    }
    return l;
  }

  /// Returns abbreviations of available languages.
  static List<String> languageAbbr() =>
      Language.values.map((e) => e.name.substring(9)).toList();

  /// Instantiates a Hyphenator with a given language
  /// configuration from JSON.
  ///
  /// `lang` follows the format `en_us` or `de_1996`.
  /// Throws if language is not found. Check  enum [Language] for
  /// complete list.
  static Future<Hyphenator> loadAsyncByAbbr(
    final String lang, {
    final String symbol = '\u{00AD}',
    final int minWordLength = 5,
    final int minLetterCount = 3,
  }) async {
    return Hyphenator(
      await LanguageConfig.load(_getLanguageEnum(lang)),
      symbol: symbol,
      minWordLength: minWordLength,
      minLetterCount: minLetterCount,
    );
  }

  /// Instantiates a Hyphenator with a given language
  /// configuration from JSON.
  static Future<Hyphenator> loadAsync(
    final Language lang, {
    final String symbol = '\u{00AD}',
    final int minWordLength = 5,
    final int minLetterCount = 3,
  }) async {
    return Hyphenator(
      await LanguageConfig.load(lang),
      symbol: symbol,
      minWordLength: minWordLength,
      minLetterCount: minLetterCount,
    );
  }

  /// Instantiates a Hyphenator with a given language
  /// configuration from Dart object.
  Hyphenator(
    final LanguageConfig config, {
    final String symbol = '\u{00AD}',
    final int minWordLength = 5,
    final int minLetterCount = 3,
  }) {
    if (minWordLength <= 0) {
      throw 'minWordLength must be > 0';
    }

    final patterns = config.data['pattern']
        .map<Pattern>((pattern) => Pattern(
            pattern['result'] as String, List<int>.from(pattern['levels'])))
        .toList()
      ..sort();

    final Map<String, List<int>> exceptions = {};

    exceptions.addEntries(
      (config.data['exception'] as Map<String, dynamic>)
          .entries
          .map((entry) => MapEntry(entry.key, List<int>.from(entry.value))),
    );

    calc = CalculationHelper(
        patterns, exceptions, minLetterCount, minWordLength, symbol);
  }

  /// Returns cached and hyphenated words.
  List<String> get cachedHyphendWords => calc.cacheHyphendWords.values.toList();

  /// Returns cached and non-hyphenated words.
  List<String> get cachedNonHyphendWords =>
      calc.cacheNonHyphendWords.values.toList();

  // RegExp reLetter = RegExp(r'\p{Letter}', unicode: true);

  /// Hyphenates a string with spaces.
  String hyphenate(final String text) {
    final currentWord = StringBuffer();
    final result = StringBuffer();
    final textUpper = text.toUpperCase();
    final textLower = text.toLowerCase();
    // final letters = text.split('');
    final len = text.length;

    for (int i = 0; i < len; i++) {
      final c = text[i];

      // FORMER
      // Results in 54 milliseconds for long test text
      //
      // final isLetter = (c == c.toLowerCase() && c == c.toUpperCase()) == false;
      //
      // GOOD
      // Results in 46 milliseconds for long test text.
      // Reduction by 15 %.
      //
      final isLetter = textLower[i] != textUpper[i];
      //
      // SO SO
      //
      // Results in 80 milliseconds for long test text.
      // Increase by 48 %.
      //
      // final isLetter = reLetter.hasMatch(c);

      if (isLetter) {
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
  String hyphenateWord(final String word) {
    if (calc.isNotNeedHyphenate(word)) return word;

    if (calc.cacheHyphendWords.containsKey(word)) {
      return calc.cacheHyphendWords[word]!;
    }
    if (calc.cacheNonHyphendWords.containsKey(word)) {
      return calc.cacheNonHyphendWords[word]!;
    }

    final result = calc.hyphenate(word);

    if (result == word) {
      calc.cacheNonHyphendWords[word] = result;
    } else {
      calc.cacheHyphendWords[word] = result;
    }
    return result;
  }

  /// Hyphenates a string and returns a list of
  /// valid hyphenations.
  List<String> hyphenateWordToList(final String word) {
    if (calc.isNotNeedHyphenate(word)) return <String>[word];

    if (calc.cacheHyphenateWordToList.containsKey(word)) {
      return calc.cacheHyphenateWordToList[word]!;
    }

    if (calc.cacheNonHyphenateWordToList.containsKey(word)) {
      return calc.cacheNonHyphenateWordToList[word]!;
    }

    final result = calc.hyphenateToList(word);

    if (result.length == 1) {
      calc.cacheNonHyphenateWordToList[word] = result;
    } else {
      calc.cacheHyphenateWordToList[word] = result;
    }
    return result;
  }
}
