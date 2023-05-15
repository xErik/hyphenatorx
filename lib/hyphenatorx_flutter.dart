import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'hyphenatorx.dart';
import 'languages/languageconfig.dart';
import 'src/token/linewrapper.dart';
import 'wrapresult.dart';

/// Wrapper class wrapping text.
///
/// [HyphenatorWrap] has implicit Flutter dependencies, as the width of the text
/// is to be calcualted by [TextPainter].
///
/// [Hyphenator] has no implicit Flutter dependencies.
class HyphenatorWrap extends Hyphenator {
  /// Instantiates a Hyphenator with a given language
  /// configuration from JSON.
  ///
  /// `lang` follows the format `en_us` or `de_1996`.
  /// Throws if language is not found. Check  enum [Language] for
  /// complete list.
  static Future<HyphenatorWrap> loadAsyncByAbbr(
    final String lang, {
    final String symbol = '\u{00AD}',
    final int minWordLength = 5,
    final int minLetterCount = 3,
  }) async {
    return HyphenatorWrap(
      await LanguageConfig.load(Hyphenator.getLanguageEnum(lang)),
      symbol: symbol,
      minWordLength: minWordLength,
      minLetterCount: minLetterCount,
    );
  }

  /// Instantiates a Hyphenator with a given language
  /// configuration from JSON.
  static Future<HyphenatorWrap> loadAsync(
    final Language lang, {
    final String symbol = '\u{00AD}',
    final int minWordLength = 5,
    final int minLetterCount = 3,
  }) async {
    return HyphenatorWrap(
      await LanguageConfig.load(lang),
      symbol: symbol,
      minWordLength: minWordLength,
      minLetterCount: minLetterCount,
    );
  }

  HyphenatorWrap(
    super.lang, {
    super.symbol = '\u{00AD}',
    super.minWordLength = 5,
    super.minLetterCount = 3,
  });

  /// Wraps the [text] with respect to the given [style] and [maxWidth].
  ///
  /// [WrapResult] holds a [Text] with the correctly hyphened [String].
  WrapResult wrap(final Text text, final TextStyle style, final maxWidth) {
    final tokens = super.hyphenateTextToTokens(text.data!);
    final wrapper = LineWrapper(tokens, text, style, maxWidth);
    final result = wrapper.render();

    return result;
  }
}
