import 'package:flutter/material.dart';
import 'package:hyphenatorx/hyphenatorx.dart';

class TextHyphenated extends StatefulWidget {
  final String text;
  final String language;
  final String symbol;
  final TextStyle? style;
  final GlobalKey? textKey;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  //
  final bool doShowDebug;

  const TextHyphenated(this.text, this.language,
      {this.symbol = '\u{00AD}',
      this.style,
      this.textKey,
      this.strutStyle,
      this.textAlign,
      this.textDirection,
      this.locale,
      this.softWrap,
      this.overflow,
      this.textScaleFactor,
      this.maxLines,
      this.semanticsLabel,
      this.textWidthBasis,
      this.textHeightBehavior,
      this.selectionColor,
      Key? super.key,
      this.doShowDebug = false});

  @override
  _TextHyphenatedState createState() => _TextHyphenatedState();
}

class _TextHyphenatedState extends State<TextHyphenated> {
  late Future<Hyphenator> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future =
        Hyphenator.loadAsyncByAbbr(widget.language, symbol: widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Hyphenator>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Hyphenator> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          throw snapshot.error!;
        }

        return LayoutBuilder(builder: (ctx, cnt) {
          final txt = _makeText(widget.text);
          final defaultStyle =
              widget.style != null ? widget.style! : TextStyle();
          final wrapped = snapshot.data!.wrap(txt, defaultStyle, cnt.maxWidth);

          final wrappedText = _makeText(wrapped.textStr);

          if (widget.doShowDebug == false) {
            return wrappedText;
          } else {
            // print(wrapped.sizeByText);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(child: wrappedText),
                Positioned(
                  right: 0,
                  bottom: -80,
                  child: Container(
                      color: wrapped.isSizeMatching
                          ? Colors.green.withAlpha(200)
                          : Colors.red.withAlpha(200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              'is-match: ' + wrapped.isSizeMatching.toString()),
                          Text('size-text : ' +
                              wrapped.debugSizeByText.width.toString() +
                              '/' +
                              wrapped.debugSizeByText.height.toString()),
                          Text('size-paint: ' +
                              wrapped.size.width.toString() +
                              '/' +
                              wrapped.size.height.toString()),
                          Text('max-width: ' + wrapped.maxWidth.toString()),
                        ],
                      )),
                ),
              ],
            );
          }
        });
      },
    );
  }

  Text _makeText(String str) {
    return Text(
      str,
      style: widget.style,
      key: widget.textKey,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }
}
