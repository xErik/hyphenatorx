import 'dart:convert';
import 'dart:io';

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

    languages
        .add('language_' + name.replaceAll('-', '_').replaceAll('hyph_', ''));

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

    _writeLanguageConfigIndividual(name, pat, exc);
  });

  _writeLanguageConfigGeneral(languages);
}

/// Writes the general language configuration file.
_writeLanguageConfigGeneral(List<String> languages) {
  String out = """
    import 'dart:convert';
    import 'package:flutter/services.dart';

    /// The PREFIX language_ protects against Dart keywords like "is"
    enum Language { ${languages.join(',')} }

    /// Auto-generated class. 
    class LanguageConfig {
      final Map<String, dynamic> _data;

      /// Constructor.
      LanguageConfig(this._data);

      /// The language configuration.
      Map<String, dynamic> get data => _data;

      /// Instantiate language configuration.
      static Future<LanguageConfig> load(Language lang) async {
        final path = 'packages/hyphenatorx/assets/\${lang.name}.json';

        final data =
          await rootBundle.loadStructuredData<Map<String, dynamic>>(path, (e) async => json.decode(e));

        return LanguageConfig(data);
      }
    }
    """;
  File('${dirLanguage.path}/languageconfig.dart').writeAsStringSync(out);
}

/// Writes a specific language configuration file.
_writeLanguageConfigIndividual(
    String name, List<String> pat, List<String> exc) {
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

      /// Auto-generated class.
      class Language$classSuffix implements LanguageConfig {
      
      /// Language configuration.
      final Map<String, dynamic> data = $js;
    }""";

  File('${dirLanguage.path}/language$classSuffix.dart').writeAsStringSync(out);

  File('${dirAssets.path}/language$classSuffix.json').writeAsStringSync(js);
}

const _exceptionDelimiter = '-';

/// Internal calculation.
/// RegExp('\\w') works only for English letters
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

/// Internal calculation.
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

/// Helper.
extension StringIsDigit on String {
  bool get isDigit => double.tryParse(this) != null;
}

/// Helper.
extension StringAsInt on String {
  int get asInt => int.parse(this);
}
