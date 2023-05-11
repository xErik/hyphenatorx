import 'dart:convert';
import 'dart:io';

import 'package:hyphenatorx/src/extensions.dart';
import 'package:path/path.dart';

final Directory dirLanguage = Directory('./lib/languages/');
final Directory dirAssets = Directory('./assets/');
final Directory dirTex = Directory('./tool/tex/');

/// DANGER! DELETES ./assets and ./lib/languages
///
/// dart run .\tool\tex2dart.dart
///
/// Combines ./tool/tex/* into
///   dart files: lib/languages/
///   json files: assets/
///
///
void main() {
  final List<String> languages = [];

  if (dirLanguage.existsSync()) {
    dirLanguage.deleteSync(recursive: true);
  }
  dirLanguage.createSync(recursive: true);
  if (dirAssets.existsSync()) {
    dirAssets.deleteSync(recursive: true);
  }
  dirAssets.createSync(recursive: true);

  final files = dirTex.listSync();

  files.forEach((file) {
    String name = basename(file.path);
    name = name.substring(0, name.lastIndexOf('.'));

    languages.add(name.replaceAll('-', '_').replaceAll('hyph_', ''));

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

    _writeFile(name, pat, exc);
  });

  _writeAbstract(languages);
}

_writeAbstract(List<String> languages) {
  String out = """
    import 'dart:convert';
    import 'package:flutter/services.dart';

    enum Language { ${languages.join(',')} }

    class LanguageConfig {
      final Map<String, dynamic> _data;

      LanguageConfig(this._data);

      Map<String, dynamic> get data => _data;

      static Future<LanguageConfig> load(Language lang) async {
        final path = 'packages/hyphenatorx/assets/language_\${lang.name}.json';

        final data =
          await rootBundle.loadStructuredData(path, (e) => json.decode(e));

        return LanguageConfig(data);
      }
    }
    """;
  File('${dirLanguage.path}/languageconfig.dart').writeAsStringSync(out);
}

_writeFile(String name, List<String> pat, List<String> exc) {
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

  File('${dirLanguage.path}/language$classSuffix.dart').writeAsStringSync(out);

  File('${dirAssets.path}/language$classSuffix.json').writeAsStringSync(js);
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
