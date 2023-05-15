import 'dart:ui';

import 'package:hyphenatorx/src/token/tokens.dart';

class TokenIterator {
  late final List<TextPartToken> _tokens;
  int _index = 0;

  TokenIterator(TextTokens tokens) {
    _tokens = tokens.parts;
  }

  bool isEmpty() => _tokens.isEmpty;
  bool hasNext() => _index < _tokens.length - 1;
  bool hasPrev() => _index > 0;
  TextPartToken current() => _tokens.elementAt(_index);
  TextPartToken next() => _tokens.elementAt(++_index);
  TextPartToken prev() => _tokens.elementAt(--_index);
  TextPartToken peek() => hasNext()
      ? _tokens.elementAt(_index + 1)
      : (TabsAndSpacesToken('')..sizeHyphen = const Size(0, 0));
}
