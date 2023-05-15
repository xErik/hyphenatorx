import 'package:flutter/material.dart';

import 'src/token/tokens.dart';

class WrapResult {
  final Text text;
  late final String textStr;
  final TextStyle style;
  final double maxWidth;
  final Size size;
  final List<List<TextPartToken>> tokens;

  WrapResult(this.text, this.style, this.maxWidth, this.size, this.tokens) {
    textStr = text.data!;
  }

  toString() {
    String ret = '>' + textStr.split('\n').join('<\n>') + '<';
    ret += '\n' + tokens.join('\n');
    return ret;
  }
}
