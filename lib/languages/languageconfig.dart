    import 'dart:convert';
    import 'package:flutter/services.dart';
import 'package:hyphenatorx/languages/language.dart';

    /// Auto-generated class. 
    class LanguageConfig {
      final Map<String, dynamic> _data;

      /// Constructor.
      LanguageConfig(this._data);

      /// The language configuration.
      Map<String, dynamic> get data => _data;

      /// Instantiate language configuration.
      static Future<LanguageConfig> load(Language lang) async {
        final path = 'packages/hyphenatorx/assets/${lang.name}.json';

        final data =
          await rootBundle.loadStructuredData<Map<String, dynamic>>(path, (e) async => json.decode(e));

        return LanguageConfig(data);
      }
    }
    