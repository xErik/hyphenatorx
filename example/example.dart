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
  String text = "subdivision";
  final controller = TextEditingController();
  late Future<Hyphenator> _future;

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
    _future = Hyphenator.load(Language.language_en_us, hyphenateSymbol: '_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Hyphenator>(
          // access a Future-field instead, this is just an example
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<Hyphenator> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final Hyphenator hyphernator = snapshot.data!;

            return Center(
                child: SizedBox(
                    width: 600,
                    child: Column(
                      children: [
                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                              hintText: 'Enter some text'),
                        ),
                        const SizedBox(height: 32),
                        text.isEmpty
                            ? const Text('Enter some text')
                            : Text(hyphernator.hyphenate(text),
                                style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 32),
                        text.isEmpty
                            ? const SizedBox.shrink()
                            : Text(
                                'Cached hyphenated:\n\n${hyphernator.cachedHyphendWords}',
                                textAlign: TextAlign.center,
                              ),
                        const SizedBox(height: 32),
                        text.isEmpty
                            ? const SizedBox.shrink()
                            : Text(
                                'Cached non-hyphenated:\n\n${hyphernator.cachedNonHyphendWords}',
                                textAlign: TextAlign.center,
                              )
                      ],
                    )));
          }),
    );
  }
}
