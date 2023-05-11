// import 'package:flutter/material.dart';
// import 'package:hyphenatorx/hyphenatorx.dart';
// import 'package:hyphenatorx/resourceloader.dart';

// class HyphenatorExampleWidget extends StatelessWidget {
//   final String text =
//       """Lorem ipsum dolor sit amet, consectetur adipiscing elit. In id magna vel lacus porttitor posuere non non turpis. Cras luctus rhoncus gravida. Cras volutpat at ligula lobortis imperdiet. Donec vehicula felis quis pharetra sagittis. Praesent porta nulla et erat malesuada viverra. Integer elit eros, laoreet tempus sagittis eu, dapibus eu nisl. Integer sed mauris congue, vestibulum ligula ac, laoreet velit. Sed posuere libero id orci interdum, non tristique arcu rhoncus. Proin placerat vitae metus id dapibus. Duis at facilisis ex. In sit amet consequat elit. Mauris vel pellentesque diam. Praesent in velit vel magna condimentum eleifend.""";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: FutureBuilder<DefaultResourceLoader>(
//           future: DefaultResourceLoader.load(
//             DefaultResourceLoaderLanguage.enUs,
//           ),
//           builder: buildText,
//         ),
//       ),
//     );
//   }

//   Widget buildText(BuildContext context, AsyncSnapshot snapshot) {
//     if (!snapshot.hasData)
//       return Center(
//         child: CircularProgressIndicator(),
//       );

//     return Text(
//       Hyphenator(resource: snapshot.data, hyphenateSymbol: '-').hyphenate(text),
//       style: TextStyle(
//         fontSize: 25,
//         height: 1.5,
//         letterSpacing: 0.6,
//       ),
//       textAlign: TextAlign.justify,
//     );
//   }
// }
