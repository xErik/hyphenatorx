import 'dart:math';

import 'package:flutter/material.dart';

abstract class TextPartToken {
  Size? sizeCurrent;
  Size? sizeHyphen;
  Size? sizeNoHyphen;
  String render();
}

class TextTokens extends TextPartToken {
  List<TextPartToken> parts;
  TextTokens(this.parts);

  toString() => parts.map<String>((e) => e.toString()).toList().toString();
  String render() => parts.map((e) => e.render()).join();

  // @override
  // Size get sizeCurrent {
  //   double wMax = 0;
  //   double hMax = 0;

  //   double wLine = 0;
  //   double hLine = 0;

  //   for (final part in parts) {
  //     if (part is WordToken || part is TabsAndSpacesToken) {
  //       wLine += part.sizeCurrent!.width;
  //       hLine = max(hLine, part.sizeCurrent!.height);
  //     } else if (part is NewlineToken) {
  //       wMax = max(wMax, wLine);
  //       hMax = hMax + hLine;
  //       wLine = 0;
  //       hLine = 0;
  //     }
  //   }

  //   return Size(wMax, hMax);
  // }
}

class WordToken extends TextPartToken {
  List<WordPartToken> parts;
  WordToken(this.parts);

  toString() => parts.map((e) => e.toString()).toList().toString();
  String render() => parts.map((e) => e.render()).join();

  @override
  Size get sizeCurrent {
    double w = 0;
    double h = 0;

    for (var part in parts) {
      w += part.sizeCurrent!.width;
      h = max(h, part.sizeCurrent!.height);
    }

    return Size(w, h);
  }
}

/// Typically a syllable. But also a syllable preceed or followed by non-word
/// characters like: "abc"
class WordPartToken extends TextPartToken {
  String text;

  WordPartToken(this.text);
  toString() => text;
  String render() => text;
  WordPartToken toHyphenAndSize(String hyphen) {
    final ret = WordPartToken(text + hyphen);
    ret.sizeCurrent = sizeHyphen;
    ret.sizeHyphen = sizeHyphen;
    ret.sizeNoHyphen = sizeNoHyphen;
    return ret;
  }
}

/// Tabs and empty spaces combined into one. NOT soft-wrap whitespace.
class TabsAndSpacesToken extends TextPartToken {
  String text;
  TabsAndSpacesToken(this.text);
  toString() => 'WS';
  String render() => text;
}

/// Tabs and empty spaces combined into one. NOT soft-wrap whitespace.
class NewlineToken extends TextPartToken {
  String text = '\n';
  toString() => 'NL';
  String render() => text;
}
