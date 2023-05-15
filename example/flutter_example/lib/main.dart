import 'package:flutter/material.dart';
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';
import 'package:hyphenatorx/widget/texthyphenated.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HyphenatorExampleWidget(),
    );
  }
}

class HyphenatorExampleWidget extends StatefulWidget {
  const HyphenatorExampleWidget({Key? key}) : super(key: key);

  @override
  _HyphenatorExampleWidgetState createState() =>
      _HyphenatorExampleWidgetState();
}

class _HyphenatorExampleWidgetState extends State<HyphenatorExampleWidget> {
  String text =
      "A vast subdivision of culture, composed of many creative endeavors and disciplines.";
  final controller = TextEditingController();
  late Future<Hyphenator> _future;
  final bold = const TextStyle(fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    controller.text = text;
    controller.addListener(() {
      setState(() {
        text = controller.text;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = Hyphenator.loadAsync(Language.language_en_us, symbol: '_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Hyphenator>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<Hyphenator> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final Hyphenator hyphernator = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                      controller: controller,
                      decoration:
                          const InputDecoration(hintText: 'Enter some text')),
                  // const SizedBox(height: 32),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                        color: Colors.green.shade50,
                        width: MediaQuery.of(context).size.width * 1 / 2,
                        child: _leftCol(hyphernator)),
                    Container(
                        color: Colors.red.shade50,
                        width: MediaQuery.of(context).size.width * 1 / 2,
                        child: _rightCol()),
                  ]),
                ],
              ),
            );
          }),
    );
  }

  Widget _rightCol() {
    return Column(
      children: [
        Text("TextHyphenated(text, 'en_us')", style: bold),
        const SizedBox(height: 16),
        Container(
          color: Colors.yellow.shade50,
          child: TextHyphenated(text, 'en_us', doShowDebug: true),
        ),
      ],
    );
  }

  Widget _leftCol(Hyphenator hyphernator) {
    return Column(
      children: [
        Text("hyphernator.hyphenateText(text)", style: bold),
        const SizedBox(height: 16),
        text.isEmpty
            ? const Text('Enter some text')
            : Text(
                hyphernator.hyphenateText(text),
                textAlign: TextAlign.center,
              ),
        const Divider(),
        text.isEmpty
            ? const SizedBox.shrink()
            : Text(
                'Cached hyphenated:\n\n${hyphernator.cachedHyphendWords}',
                textAlign: TextAlign.center,
              ),
        const Divider(),
        text.isEmpty
            ? const SizedBox.shrink()
            : Text(
                'Cached non-hyphenated:\n\n${hyphernator.cachedNonHyphendWords}',
                textAlign: TextAlign.center,
              ),
      ],
    );
  }
}
