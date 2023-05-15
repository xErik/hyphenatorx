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
  toString() => text + ' c:${sizeCurrent} h:${sizeHyphen} no-h:${sizeNoHyphen}';
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
