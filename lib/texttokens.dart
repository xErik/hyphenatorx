import 'package:flutter/material.dart';

// Convenience field for later usage by consumer.
abstract class Sized {
  Size? size;
  int get length;
}

class TextTokens {
  List<TextPartToken> parts;
  TextTokens(this.parts);

  toString() => parts.map<String>((e) => e.toString()).toList().toString();
}

abstract class TextPartToken {}

class WordToken extends TextPartToken with Sized {
  List<WordPartToken> parts;
  WordToken(this.parts);

  int get length => parts.fold<int>(0, (sum, item) => sum + item.length);

  toString() => parts.map((e) => e.toString()).toList().toString();
}

/// Typically a syllable. But also a syllable preceed or followed by non-word
/// characters like: "abc"
class WordPartToken with Sized {
  String text;
  WordPartToken(this.text);

  int get length => text.length;

  toString() => text;
}

/// Tabs and empty spaces combined into one. NOT soft-wrap whitespace.
class TabsAndSpacesToken extends TextPartToken with Sized {
  String text;
  TabsAndSpacesToken(this.text);

  int get length => text.length;

  toString() => 'WS';
}

/// Tabs and empty spaces combined into one. NOT soft-wrap whitespace.
class NewlineToken extends TextPartToken with Sized {
  String text = '\n';

  int get length => 0;

  toString() => 'NL';
}
