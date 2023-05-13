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
      Key? super.key});

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

        return Text(
          snapshot.data!.hyphenate(widget.text),
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
      },
    );
  }
}
