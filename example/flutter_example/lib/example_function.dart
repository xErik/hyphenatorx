import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyphenatorx/hyphenatorx.dart';

class ExampleFunction extends StatefulWidget {
  const ExampleFunction({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ExampleFunctionState createState() => _ExampleFunctionState();
}

class _ExampleFunctionState extends State<ExampleFunction> {
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
    _future = Hyphenator.loadAsyncByAbbr('en_us', symbol: '_');
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
                  const SizedBox(height: 16),
                  Text(
                      "(await Hyphenator.loadAsyncByAbbr('en_us', symbol: '_')).hyphenateText(text)",
                      style: GoogleFonts.robotoMono().copyWith(
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.yellow.shade200)),
                  // const Divider(),
                  TextField(
                      controller: controller,
                      decoration:
                          const InputDecoration(hintText: 'Enter some text')),
                  const SizedBox(height: 16),
                  _colum(hyphernator),
                ],
              ),
            );
          }),
    );
  }

  Widget _colum(Hyphenator hyphernator) {
    return text.isEmpty
        ? const SizedBox.shrink()
        : Column(
            children: [
              Text(
                hyphernator.hyphenateText(text),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text('Cache Hyphenated:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono()
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                '${hyphernator.cachedHyphendWords}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text('Cache Non-Hyphenated:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono()
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                '${hyphernator.cachedNonHyphendWords}',
                textAlign: TextAlign.center,
              ),
            ],
          );
  }
}
