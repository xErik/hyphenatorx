import 'package:flutter/material.dart';

import 'example_function.dart';
import 'example_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Function Call'),
                Tab(text: 'Text Widget'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ExampleFunction(),
              ExampleWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
