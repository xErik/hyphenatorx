import 'package:flutter/material.dart';
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HyphenatorExampleWidget(),
    );
  }
}

class HyphenatorExampleWidget extends StatelessWidget {
  final String text = "subdivision.";

  const HyphenatorExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<Hyphenator>(
            // access a Future-field instead, this is just an example
            future:
                Hyphenator.load(Language.language_en_us, hyphenateSymbol: '_'),
            builder:
                (BuildContext context, AsyncSnapshot<Hyphenator> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final Hyphenator hyphernator = snapshot.data!;

              return Text(hyphernator.hyphenate(text));
            }),
      ),
    );
  }
}
