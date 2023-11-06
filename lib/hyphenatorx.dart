import 'dart:core';

import 'package:flutter/material.dart';
import 'package:hyphenatorx/languages/language.dart';
import 'package:hyphenatorx/src/extensions.dart';

import 'languages/languageconfig.dart';
import 'src/calculationhelper.dart';
import 'src/letterutil.dart';
import 'src/pattern.dart';
import 'token/linewrapperhyphen.dart';
import 'token/linewrappernohyphen.dart';
import 'token/tokens.dart';
import 'token/wrapresult.dart';

/// Wrapper class hyphenating text.
class Hyphenator {
  late final CalculationHelper calc;
  static final RegExp _reBoundaries = RegExp(r'[\t\ ]+');
  static final RegExp _split = RegExp(r'\n|[\t ]+');



  /// Instantiates a Hyphenator with a given language
  /// configuration from JSON.
  ///
  /// `lang` follows the format `en_us` or `de_1996`.
  /// Throws if language is not found. Check  enum [Language] for
  /// complete list.
  static Future<Hyphenator> loadAsyncByAbbr(
    final Language lang, {
    final String symbol = '\u{00AD}',
    final String hyphen = '-',
    final int minWordLength = 5,
    final int minLetterCount = 3,
  }) async {
    return Hyphenator(
      await LanguageConfig.load(lang),
      symbol: symbol,
      hyphen: hyphen,
      minWordLength: minWordLength,
      minLetterCount: minLetterCount,
    );
  }

  /// Instantiates a Hyphenator with a given language
  /// configuration from JSON.
  static Future<Hyphenator> loadAsync(
    final Language lang, {
    final String symbol = '\u{00AD}',
    final String hyphen = '-',
    final int minWordLength = 5,
    final int minLetterCount = 3,
  }) async {
    return Hyphenator(
      await LanguageConfig.load(lang),
      symbol: symbol,
      hyphen: hyphen,
      minWordLength: minWordLength,
      minLetterCount: minLetterCount,
    );
  }

  /// Instantiates a Hyphenator with a given language
  /// configuration from Dart object.
  Hyphenator(
    final LanguageConfig config, {
    final String symbol = '\u{00AD}',
    final String hyphen = '-',
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
        patterns, exceptions, minLetterCount, minWordLength, symbol, hyphen);
  }

  /// Returns cached and hyphenated words.
  List<String> get cachedHyphendWords => calc.cacheHyphendWords.values.toList();

  /// Returns cached and non-hyphenated words.
  List<String> get cachedNonHyphendWords =>
      calc.cacheNonHyphendWords.values.toList();

  /// Wraps the [text] with respect to the given [style] and [maxWidth].
  ///
  /// [WrapResult] holds a [Text] with the correctly hyphened [String].
  WrapResult wrap(final Text text, final TextStyle style, final maxWidth) {
    final tokens = hyphenateTextToTokens(text.data!);
    final wrapper =
        LineWrapperHyphen(tokens, text, style, maxWidth, calc.hyphen);
    return wrapper.render();
  }

  /// Service method to wrap a text and NOT perform hyphenation.
  static WrapResult wrapNoHyphen(
      final Text text, final TextStyle style, final double maxWidth) {
    final List<TextPartToken> tokens = [];

    final List<String> parts =
        text.data!.replaceAll(reR, '').splitWithDelim(_split);

    for (final part in parts) {
      if (part.isEmpty) {
        // hu?!
      } else if (part == '\n') {
        tokens.add(NewlineToken());
      } else if (part.trim().isEmpty) {
        tokens.add(TabsAndSpacesToken(part));
      } else {
        tokens.add(WordToken([WordPartToken(part)]));
      }
    }
    // print(tokens);
    final wrapper = LineWrapperNoHyphen(tokens, text, style, maxWidth);
    return wrapper.render();
  }

  /// Hyphenates a text and returns this text broken down into a tree.
  /// Each node being a potential candidate for leding and triling hyphenation.
  ///
  /// WordPartToken is not only a pure syllable, but includes directly
  /// leading or trailing other symbols like punctuation.
  ///
  /// Returns a tree:
  ///
  /// TextTokens
  ///   - WordToken (many syllables)
  ///     - WordPartToken (syllables and surrounding symbols)
  ///   - TabsAndSpacesToken
  ///   - NewlineToken
  ///
  /// The actual result looks like this, WS meaning Whitespace and NL Newline:
  ///
  /// [[The], WS, [arts], WS, [are], WS, [a], NL, [vast], WS, [sub, di, vi, sion], WS]
  ///
  static final reR = RegExp(r'\r');
  List<TextPartToken> hyphenateTextToTokens(final String text) {
    final List<TextPartToken> tokens = [];

    final String hyph = hyphenateText(text); // this is expensive

    final List<String> parts = hyph.replaceAll(reR, '').splitWithDelim(_split);

    for (final part in parts) {
      if (part.isEmpty) {
        // hu?!
      } else if (part == '\n') {
        tokens.add(NewlineToken());
      } else if (part.trim().isEmpty) {
        tokens.add(TabsAndSpacesToken(part));
      } else {
        // Word
        tokens.add(WordToken(part
            .split(calc.symbol)
            .map<WordPartToken>((e) => WordPartToken(e))
            .toList(growable: false)));
      }
    }

    return tokens;
  }

  /// Hyphenates a text.
  ///
  /// The hyphen symbol will be placed inside words only.
  ///
  /// Setting `hyphenAtBoundaries: false` will add additional
  /// hyphens at the outer word boundaries, including punctutation etc.
  ///
  /// @TODO rewrite this into a proper parser?
  String hyphenateText(final String text, {hyphenAtBoundaries = false}) {
    final currentWord = StringBuffer();
    final result = StringBuffer();
    final textUpper = text.toUpperCase();
    final textLower = text.toLowerCase();
    final len = text.length;

    for (int i = 0; i < len; i++) {
      final c = text[i];

      // FORMER
      //
      // final isLetter = (c == c.toLowerCase() && c == c.toUpperCase()) == false;
      //
      // GOOD
      //
      bool isLetter = LetterUtil.isLetter(c) || textLower[i] != textUpper[i];
      //
      // SO SO
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

    // calc.logCache();

    if (hyphenAtBoundaries == false) {
      return result.toString();
    } else {
      // Lazy method to add a hyphen symbol to word boundaries,
      // including punctuation etc. following or preceeding a syllable.
      return result.toString().splitWithDelim(_reBoundaries).join(calc.symbol);
    }
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

  /// Returns syllables of a single word, being candidates for hyphenation.
  List<String> syllablesWord(final String word) {
    if (calc.isNotNeedHyphenate(word)) return <String>[word];

    if (calc.cacheHyphenateSyllables.containsKey(word)) {
      return calc.cacheHyphenateSyllables[word]!;
    }

    if (calc.cacheNonHyphenateSyllables.containsKey(word)) {
      return calc.cacheNonHyphenateSyllables[word]!;
    }

    final result = calc.syllables(word);

    if (result.length == 1) {
      calc.cacheNonHyphenateSyllables[word] = result;
    } else {
      calc.cacheHyphenateSyllables[word] = result;
    }
    return result;
  }
}
