import 'package:hyphenatorx/token/tokens.dart';

class TokenIterator {
  late final List<TextPartToken> _tokens;
  int _index = 0;

  TokenIterator(List<TextPartToken> this._tokens);

  bool isEmpty() => _tokens.isEmpty;
  bool hasNext() => _index < _tokens.length - 1;
  // bool hasPrev() => _index > 0;
  TextPartToken current() => _tokens.elementAt(_index);
  TextPartToken next() => _tokens.elementAt(++_index);
  // TextPartToken prev() => _tokens.elementAt(--_index);
  // TextPartToken peek() => hasNext()
  // ? _tokens.elementAt(_index + 1)
  // : (TabsAndSpacesToken('')..sizeHyphen = const Size(0, 0));
}
