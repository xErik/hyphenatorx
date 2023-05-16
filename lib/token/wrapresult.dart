import 'dart:math';

import 'package:flutter/material.dart';

import 'tokens.dart';

class WrapResult {
  final Text text;
  late final String textStr;
  final TextStyle style;
  final double maxWidth;
  final Size size;
  final List<List<TextPartToken>> tokens;
  late final bool isSizeMatching;

  WrapResult(this.text, this.style, this.maxWidth, this.size, this.tokens) {
    textStr = text.data!;
    isSizeMatching = size.width <= maxWidth;
  }

  toString() {
    String ret = '>' + textStr.split('\n').join('<\n>') + '<';
    ret += '\n' + tokens.join('\n');
    ret += '\n' + size.toString() + ' vs. max-width: $maxWidth';
    ret += '\nfontSize: ${style.fontSize}';
    ret += '\nisSizeMatching: $isSizeMatching';
    return ret;
  }

  Size get debugSizeByText {
    double wMax = 0;
    double hMax = 0;

    double wLine = 0;
    double hLine = 0;

    for (final line in tokens) {
      for (final part in line) {
        if (part is WordPartToken) {
          wLine += part.sizeCurrent!.width;
          hLine = max(hLine, part.sizeCurrent!.height);
        } else if (part is TabsAndSpacesToken) {
          wLine += part.sizeCurrent!.width;
          hLine = max(hLine, part.sizeCurrent!.height);
        }
      }

      wMax = max(wMax, wLine);
      hMax = hMax + hLine;
      wLine = 0;
      hLine = 0;
    }

    return Size(wMax, hMax);
  }

  String get debugSizeOfLines {
    String ret = '';

    double wMax = 0;
    double hMax = 0;

    double wLine = 0;
    double hLine = 0;

    for (final line in tokens) {
      for (final part in line) {
        if (part is WordPartToken) {
          wLine += part.sizeCurrent!.width;
          hLine = max(hLine, part.sizeCurrent!.height);
        } else if (part is TabsAndSpacesToken) {
          wLine += part.sizeCurrent!.width;
          hLine = max(hLine, part.sizeCurrent!.height);
        }
      }

      ret += line.toString() + ' width:$wLine\n';

      wMax = max(wMax, wLine);
      hMax = hMax + hLine;
      wLine = 0;
      hLine = 0;
    }

    return ret;
  }
}
