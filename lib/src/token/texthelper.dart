import 'package:flutter/widgets.dart';

class TextHelper {
  static Text clone(Text t, String str) {
    return Text(
      str,
      style: t.style,
      strutStyle: t.strutStyle,
      textAlign: t.textAlign,
      textDirection: t.textDirection,
      locale: t.locale,
      softWrap: t.softWrap,
      overflow: t.overflow,
      // Android has scaling larger than 1.0 set,
      // thus the measurements appear to be not right
      // if this is not 1.0 and consumd?
      // textScaleFactor: 1.0,
      textScaleFactor: t.textScaleFactor,
      maxLines: t.maxLines,
      semanticsLabel: t.semanticsLabel,
      textWidthBasis: t.textWidthBasis,
      textHeightBehavior: t.textHeightBehavior,
      selectionColor: t.selectionColor,
    );
  }
}
