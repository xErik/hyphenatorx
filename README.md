# Hyphenator

Implementation of an hyphenation algorithm.

The hyphen symbol can be defined, the default is the soft-wrap `'\u{00AD}'`.

The `tex` patterns used in the algorithm can be found [here](https://tug.org/tex-hyphen/).

The package seems to work fine for western languages, other languages have to be evaluated.

A live Flutter demo: [https://xerik.github.io/hyphenatorx/](https://xerik.github.io/hyphenatorx/).

## Installation

```shell
flutter pub add hyphenatorx
```

## Usage

Hyphenator instantiates a language specific configuration:

**As a Dart object** 

Without synchronous loading. The data is compiled into your project. All 71 langauge files together have a size of 13.3 MB.
  
**From JSON**

With asynchronous loading. The data will be loaded as needed from the local `assets` folder. This option is less memory intensive.

**Languages**

Available languages are given by the `enum Language`.

**Cache**

Internally, hyphenated as well as non-hyphenated words are cached. Complete texts are not cached, only single words.

### Asynchronous Instantiation

Select the appropriate `Language.language_XX` value.

Or set a language code like `en_us`.

```dart
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';

final hyphernator = await Hyphenator.loadAsyn(
    Language.language_en_us, 
    hyphenateSymbol: '_');

// OR THIS:

final hyphernator = await Hyphenator.loadAsyncByAbbr(
    'en_us', 
    hyphenateSymbol: '_');

expect(
  hyphenator.hyphenate('subdivision subdivision'), 
  'sub_di_vi_sion sub_di_vi_sion');

expect(
  hyphenator.hyphenateWord('subdivision'),
  'sub_di_vi_sion');

expect(
  hyphenator.hyphenateWordToList('subdivision'),
  ['sub', 'di', 'vi', 'sion']);
```

### Synchronous Instantiation

Instatiate the appropriate `Language_XX()` object.

```dart 
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';

final LanguageConfig config = Language_en_us();

final hyphenator = Hyphenator(
  config,
  hyphenateSymbol: '_',
);

expect(
  hyphenator.hyphenate('subdivision subdivision'), 
  'sub_di_vi_sion sub_di_vi_sion');

expect(
  hyphenator.hyphenateWord('subdivision'),
  'sub_di_vi_sion');

expect(
  hyphenator.hyphenateWordToList('subdivision'),
  ['sub', 'di', 'vi', 'sion']);
```

### Widget 

This is a convenience Widget, rendering a `Text`. The default symbol is the soft-wrap `'\u{00AD}'`.;

```dart 
import 'package:hyphenatorx/texthyphenated.dart';

const TextHyphenated('subdivision', 'en_us', symbol: '@'),

/// renders: sub@di@vi@sion
```


## Languages and Abbreviations

The abbreviations correspond with the `tex` file names [here](https://tug.org/tex-hyphen/).

### Strings 

```dart
List<String> abbr = Hyphenator.languageAbbr();

print(abbr); 

// [af, as, bg, bn, ca, .., zh_latn_pinyin]
```

### Enum

As Islandic is been abbreviated "is", which is a Dart keyword, the prefix "language" had been added.

```dart 
enum Language { language_af,language_as,language_bg,language_bn,language_ca,language_cop,language_cs,language_cy,language_da,language_de_1901,language_de_1996,language_de_ch_1901,language_el_monoton,language_el_polyton,language_en_gb,language_en_us,language_eo,language_es,language_et,language_eu,language_fi,language_fr,language_fur,language_ga,language_gl,language_grc,language_gu,language_hi,language_hr,language_hsb,language_hu,language_hy,language_ia,language_id,language_is,language_it,language_ka,language_kmr,language_kn,language_la_x_classic,language_la,language_lt,language_lv,language_ml,language_mn_cyrl_x_lmc,language_mn_cyrl,language_mr,language_mul_ethi,language_nb,language_nl,language_nn,language_or,language_pa,language_pl,language_pms,language_pt,language_rm,language_ro,language_ru,language_sa,language_sh_cyrl,language_sk,language_sl,language_sv,language_ta,language_te,language_th,language_tk,language_tr,language_uk,language_zh_latn_pinyin }
```

## Performance

Old machine:

* Instantiation via Dart EN_US file: 30 milliseconds
* Hyphenating text with 258 words: 46 milliseconds

Internal testing whether a character is a letter impacts performance the most.

```dart
// FORMER
//
// Results in 54 milliseconds for long text.
//
// final isLetter = (c == c.toLowerCase() && c == c.toUpperCase()) == false;

// BETTER
//
// Results in 46 milliseconds for long text.
// Reduction by 15 %.
//
// final isLetter = textLower[i] != textUpper[i];

// INCREASE, but most precise?
//
// Results in 80 milliseconds for long text.
// Increase by 48 %.
//
// final reLetter = RegExp(r'\p{Letter}', unicode: true);
// final isLetter = reLetter.hasMatch(c);
```

## Generate JSON and Dart files

```
dart run ./tool/tex2dart.dart
```

The tool will delete `assets` and `lib/languages` before generating new files. It processes tex files located in `tool\tex\`.

## Source

This package is a copy and extension of [hyphenator](https://pub.dev/packages/hyphenator).


## Outlook

* Implementing real hyphenation with hyphenations ending in `-`?
* Performance improvement.