import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyphenatorx/languages/language.dart';
import 'package:hyphenatorx/widget/texthyphenated.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ExampleWidgetState createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  String text =
      "A vast subdivision of culture, composed of many creative endeavors and disciplines.";
  final controller = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "TextHyphenated(text, 'en_us', doShowDebug: true, style: const TextStyle(fontSize: 56))",
            style: GoogleFonts.robotoMono().copyWith(
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.yellow.shade200),
          ),
          // const Divider(),
          TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter some text')),
          const SizedBox(height: 16),
          TextHyphenated(text, Language.language_en_us,
              doShowDebug: true, style: const TextStyle(fontSize: 56)),
        ],
      ),
    ));
  }
}
