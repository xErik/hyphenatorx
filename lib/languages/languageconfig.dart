    import 'dart:convert';
    import 'package:flutter/services.dart';

    enum Language { da,de_1996,en_us }

    class LanguageConfig {
      final Map<String, dynamic> _data;

      LanguageConfig(this._data);

      Map<String, dynamic> get data => _data;

      static Future<LanguageConfig> load(Language lang) async {
        final path = 'packages/hyphenatorx/assets/language_${lang.name}.json';

        final data =
          await rootBundle.loadStructuredData(path, (e) => json.decode(e));

        return LanguageConfig(data);
      }
    }
    