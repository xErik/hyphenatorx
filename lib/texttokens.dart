import 'dart:math';

import 'package:flutter/material.dart';

abstract class TextPartToken {
  Size? sizeCurrent;
  Size? sizeHyphen;
  Size? sizeNoHyphen;
  int get length;
  String render();
}

class TextTokens {
  List<TextPartToken> parts;
  TextTokens(this.parts);

  int get length => parts.fold<int>(0, (sum, item) => sum + item.length);
  toString() => parts.map<String>((e) => e.toString()).toList().toString();
  String render() => parts.map((e) => e.render()).join();
}

class WordToken extends TextPartToken {
  List<WordPartToken> parts;
  WordToken(this.parts);

  int get length => parts.fold<int>(0, (sum, item) => sum + item.length);
  toString() => parts.map((e) => e.toString()).toList().toString();
  String render() => parts.map((e) => e.render()).join();
}

/// Typically a syllable. But also a syllable preceed or followed by non-word
/// characters like: "abc"
class WordPartToken extends TextPartToken {
  String text;

  WordPartToken(this.text);
  int get length => text.length;
  toString() => text;
  String render() => text;
  WordPartToken toHyphenAndSize(String hyphen) =>
      WordPartToken(text + hyphen)..sizeCurrent = sizeHyphen;
}

/// Tabs and empty spaces combined into one. NOT soft-wrap whitespace.
class TabsAndSpacesToken extends TextPartToken {
  String text;
  TabsAndSpacesToken(this.text);
  int get length => text.length;
  toString() => 'WS';
  String render() => text;
}

/// Tabs and empty spaces combined into one. NOT soft-wrap whitespace.
class NewlineToken extends TextPartToken {
  String text = '\n';
  int get length => 0;
  toString() => 'NL';
  String render() => text;
}

class TextTokenIterator {
  late final List<TextPartToken> _tokens;
  int _index = 0;

  TextTokenIterator(TextTokens tokens) {
    _tokens = tokens.parts;
  }

  bool isEmpty() => _tokens.isEmpty;
  bool hasNext() => _index < _tokens.length;
  bool hasPrev() => _index > 0;
  TextPartToken current() => _tokens.elementAt(_index);
  TextPartToken next() => _tokens.elementAt(_index++);
  TextPartToken prev() => _tokens.elementAt(_index--);
  TextPartToken peek() => hasNext()
      ? _tokens.elementAt(_index + 1)
      : (TabsAndSpacesToken('')..sizeHyphen = const Size(0, 0));
}
