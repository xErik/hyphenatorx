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
}
