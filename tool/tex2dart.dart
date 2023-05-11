import 'dart:convert';
import 'dart:io';

import 'package:hyphenatorx/src/extensions.dart';
import 'package:path/path.dart';

/// Combines ./tool/tex/* into
///   dart files: lib/languages/
///   json files: assets/
///
/// dart run .\tool\tex2dart.dart
///
void main() {
  final List<String> languages = [];

  Directory('./lib/languages/').deleteSync();
  Directory('./assets/').deleteSync();

  final files = Directory('./tool/tex/').listSync();

  files.forEach((file) {
    String name = basename(file.path);
    name = name.substring(0, name.lastIndexOf('.'));

    languages.add(name.replaceAll('-', '_'));

    List<String> lines = File(file.path)
        .readAsLinesSync()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.startsWith('%') == false)
        .toList();

    final pat = <String>[];
    final exc = <String>[];

    bool isNextPattern = false;
    bool isNextException = false;

    for (final line in lines) {
      if (line.startsWith('}')) {
        isNextPattern = false;
        isNextException = false;
      } else if (!isNextPattern && line.startsWith('\\patterns')) {
        isNextPattern = true;
      } else if (!isNextException && line.startsWith('\\hyphenation')) {
        isNextException = true;
      } else if (isNextPattern && !isNextException) {
        pat.add(line);
      } else if (isNextException) {
        exc.add(line);
      }
    }

    writeFile(name, pat, exc);
  });

  writeAbstract(languages);
}

writeAbstract(List<String> languages) {
  String out = """
    import 'dart:convert';
    import 'package:flutter/services.dart';

    enum Language { ${languages.join(',')} }

    abstract class LanguageConfig {
    
      Map<String, dynamic> get data;
    
      static Future<LanguageConfig> load(Language lang) async {
        return await rootBundle.loadStructuredData(
          'packages/hyphenatorx/assets/language_\${lang.name}.json',
          (e) => json.decode(e));
      }

    }""";
  File('./lib/languages/languageconfig.dart').writeAsStringSync(out);
}

writeFile(String name, List<String> pat, List<String> exc) {
  final classSuffix = name.replaceAll('hyph-', '_').replaceAll('-', '_');

  final List<Map<String, dynamic>> patterns = [];
  patterns.addAll(pat.map((e) => _patternFromString(e)));

  final Map<String, List<int>> exceptions = {};
  exceptions.addEntries(exc.map((e) => MapEntry(
      e.replaceAll(_exceptionDelimiter, ''), _exceptionMaskFromString(e))));

  Map<String, dynamic> data = {
    'pattern': patterns,
    'exception': exceptions,
  };

  final js = json.encode(data);

  String out = """
    import "./languageconfig.dart";
      class Language$classSuffix implements LanguageConfig {
      final Map<String, dynamic> data = $js;
    }""";

  File('./lib/languages/language$classSuffix.dart').writeAsStringSync(out);

  File('./assets/language$classSuffix.json').writeAsStringSync(js);
}

const _exceptionDelimiter = '-';

// RegExp('\\w') works only for English letters
List<int> _exceptionMaskFromString(String exc) {
  final list = <int>[];
  int index = 0;

  while (index < exc.length) {
    if (exc[index] == _exceptionDelimiter) {
      list.add(1);
      index++;
    } else {
      list.add(0);
    }
    index++;
  }
  list.add(0);
  return list;
}

Map<String, dynamic> _patternFromString(String pattern) {
  final levels = <int>[];
  String result = '';

  bool waitDigit = true;
  for (int i = 0; i < pattern.length; i++) {
    final c = pattern[i];

    if (c.isDigit) {
      levels.add(c.asInt);
      waitDigit = false;
    } else {
      if (waitDigit) levels.add(0);
      result = result + c;
      waitDigit = true;
    }
  }

  if (waitDigit) levels.add(0);

  return {
    'result': result,
    'levels': levels,
  };
}
