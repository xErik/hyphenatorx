    import 'dart:convert';
    import 'package:flutter/services.dart';

    enum Language { hyph_da,hyph_de_1996,hyph_en_us }

    abstract class LanguageConfig {
    
      Map<String, dynamic> get data;
    
      static Future<LanguageConfig> load(Language lang) async {
        return await rootBundle.loadStructuredData(
          'packages/hyphenatorx/assets/language_${lang.name}.json',
          (e) => json.decode(e));
      }

    }