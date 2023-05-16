import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hyphenatorx/src/token/texthelper.dart';

import '../src/token/tokeniterator.dart';
import 'tokens.dart';
import 'wrapresult.dart';

/// Hyphenates tokens with respect to the attributes of
/// [Text], [TextStyle] and [maxWidth].
class LineWrapper {
  final String _hyphen = '-';
  late final double _maxWidth;
  final List<List<TextPartToken>> _lines = [];
  late final TextPainter _painter;
  final TextStyle _style;
  double maxSyllableWidth = 0;
  late final TokenIterator _tokenIter;
  final Text _text;

  /// Constructor.
  LineWrapper(TextTokens tokens, this._text, this._style, this._maxWidth) {
    final Map<String, Size> tokensWidthCache = {};
    _tokenIter = TokenIterator(tokens);

    _painter = TextPainter(
      textDirection: _text.textDirection ?? TextDirection.ltr,
      maxLines: _text.maxLines,
      textScaleFactor: _text.textScaleFactor ?? 1.0,
      locale: _text.locale,
      textAlign: _text.textAlign ?? TextAlign.start,
      textHeightBehavior: _text.textHeightBehavior,
      textWidthBasis: _text.textWidthBasis ?? TextWidthBasis.parent,
    );

    for (final TextPartToken part in tokens.parts) {
      if (part is WordToken) {
        for (final WordPartToken p in part.parts) {
          _setWidths(p.text, tokensWidthCache, p);
        }
      } else if (part is TabsAndSpacesToken) {
        _setWidths(part.text, tokensWidthCache, part);
      } else if (part is NewlineToken) {
        part.sizeHyphen = const Size(0, 0);
        part.sizeNoHyphen = const Size(0, 0);
        part.sizeCurrent = const Size(0, 0);
      }
    }

    // print('=== CACHE: ${tokensWidthCache}');
  }

  /// Sets the widths of the token with respect to hyphend and not-hyphened.
  void _setWidths(String syllable, Map<String, Size> tokensWidthCache,
      TextPartToken token) {
    final syllableHyphened = '$syllable$_hyphen';

    if (tokensWidthCache[syllable] == null) {
      _painter.text = TextSpan(text: syllable, style: _style);
      _painter.layout();
      tokensWidthCache[syllable] = _painter.size;

      _painter.text = TextSpan(text: syllableHyphened, style: _style);
      _painter.layout();
      tokensWidthCache[syllableHyphened] = _painter.size;
    }

    final Size sizeNoHyphen = tokensWidthCache[syllable]!;
    final Size sizeHyphen = tokensWidthCache[syllableHyphened]!;

    token.sizeHyphen = sizeHyphen;
    token.sizeNoHyphen = sizeNoHyphen;
    token.sizeCurrent = sizeNoHyphen;
    maxSyllableWidth = max(maxSyllableWidth, sizeNoHyphen.width);
  }

  /// Returns the resulting String with hyphens and linebreaks.
  ///
  /// Calls [lines] implicitly.
  WrapResult render() {
    if (_tokenIter.isEmpty()) {
      return WrapResult(_text, _style, _maxWidth, Size(0, 0), _lines);
    }

    List<TextPartToken> line = [];

    while (true) {
      var token = _tokenIter.current();

      // ------------------------------------------------------------
      // NEWLINE
      // ------------------------------------------------------------
      if (token is NewlineToken) {
        _lines.add([NewlineToken()]);
        line.clear();
      } else
      // ------------------------------------------------------------
      // TABS AND SPACES
      // ------------------------------------------------------------
      if (token is TabsAndSpacesToken && line.isNotEmpty) {
        if (_canAddNoHyphen([token], line)) {
          line.add(token);
        } else {
          _lines.add(_cloneLineAndAddNewline(line));
          line.clear();
        }
      } else
      // ------------------------------------------------------------
      // WORD
      // ------------------------------------------------------------
      if (token is WordToken) {
        // print('ADING WORD TO LINE');
        bool trySuccess = _tryAddWordToLine(token, line);

        if (trySuccess == false) {
          // print('ADING WORD TO EMPTY LINE');
          _lines.add(_cloneLineAndAddNewline(line));
          line.clear();
          trySuccess = _tryAddWordToLine(token, line);
          if (trySuccess == false) {
            // print('ADING WORD TO NEW EMPTY LINE -- FORCED');
            _lines.add(_cloneLineAndAddNewline(line));
            line.clear();
          }
        }
      }

      // ------------------------------------------------------------
      // NEXT TOKEN
      // ------------------------------------------------------------

      if (_tokenIter.hasNext()) {
        _tokenIter.next();
      } else {
        break;
      }
    }
    if (line.isNotEmpty) {
      _lines.add(line);
    }

    final str =
        _lines.map<String>((line) => line.map((e) => e.render()).join()).join();
    _painter.text = TextSpan(text: str, style: _style);
    _painter.layout();

    final wrap = WrapResult(
        TextHelper.clone(_text, str), _style, _maxWidth, _painter.size, _lines);

    if (kDebugMode) {
      print('RENDERED lines   paint:\n${wrap.debugSizeOfLines}');
      print('RENDERED string  paint:\n$str');
      print('RENDERED size by paint: ${_painter.size}');
      print('RENDERED size by token: ${wrap.debugSizeByText}');
      print('RENDERED      maxWidth: ${wrap.maxWidth}');
    }
    return wrap;
  }

  bool _tryAddWordToLine(WordToken token, List<TextPartToken> line) {
    final partLength = token.parts.length;
    List<WordPartToken> prelist = [];
    List<WordPartToken> postlist = [];

    for (int i = partLength; i > 0; i--) {
      prelist = token.parts.sublist(0, i);
      postlist = token.parts.sublist(i, partLength);

      if (i == partLength && _canAddNoHyphen(prelist, line)) {
        line.addAll([...prelist]); // add all word parts
        prelist.clear();
        postlist.clear();
        break;
      } else if (_canAddHyphenlast(prelist, line)) {
        line.addAll(_doHyphenLast(prelist));
        _lines.add(_cloneLineAndAddNewline(line));
        line.clear();
        line.addAll(postlist);
        prelist.clear();
        postlist.clear();
        break;
      }
    }
    return prelist.isEmpty && postlist.isEmpty;
  }

  List<TextPartToken> _cloneLineAndAddNewline(List<TextPartToken> line) {
    final clone = [...line];
    while (clone.last is TabsAndSpacesToken) {
      clone.removeLast();
    }
    clone.add(NewlineToken());
    return clone;
  }

  bool _canAddNoHyphen(
      final List<TextPartToken> tokens, List<TextPartToken> line) {
    double w = line.fold<double>(0, (sum, item) {
      return sum + item.sizeCurrent!.width;
    });

    w += tokens.fold<double>(0, (sum, item) {
      return sum + item.sizeCurrent!.width;
    });

    return w <= _maxWidth;
  }

  bool _canAddHyphenlast(
      final List<WordPartToken> tokens, List<TextPartToken> line) {
    double w = line.fold(0, (sum, item) => sum + item.sizeCurrent!.width);

    w += _doHyphenLast(tokens)
        .fold<double>(0, (sum, item) => sum + item.sizeCurrent!.width);

    return w <= _maxWidth;
  }

  List<TextPartToken> _doHyphenLast(List<WordPartToken> tokens) {
    return tokens.sublist(0, tokens.length - 1)
      ..add(tokens.last.toHyphenAndSize(_hyphen));
  }
}
