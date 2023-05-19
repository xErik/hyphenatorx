# Hyphenator

Implementation of an hyphenation algorithm.

* Offers a `Widget` hyphenating a `String` and wrapping the result based on the available width.
* Offers various function calls to hyphenate a `String` at all possible positions. 

The `tex` patterns used in the algorithm can be at [tug.org](https://tug.org/tex-hyphen/).

The package seems to work fine for western languages, other languages have to be evaluated.

Test the live demo [https://xerik.github.io/hyphenatorx/](https://xerik.github.io/hyphenatorx/).

**Wrapping and Scaling Text**

The package [text_wrap_auto_size](https://pub.dev/packages/text_wrap_auto_size) uses
`hyphenatorx` for wrapping and auto scaling text - with and without hyphenation.

## Quickstart

```dart 
import 'package:hyphenatorx/texthyphenated.dart';

// sub-
// di-
// vi-
// sion
TextHyphenated('subdivision', 
  'en_us',
  style: TextStyle(fontSize: 56))
```

```dart
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';

final hyphenator = Hyphenator(Language_en_us(), symbol: '_');

// 'sub_di_vi_sion_ _sub_di_vi_sion'
print(
  hyphenator.hyphenateText('subdivision subdivision', 
    hyphenAtBoundaries: true));

// sub_di_vi_sion sub_di_vi_sion
print(hyphenator.hyphenateText('subdivision subdivision'));

// sub_di_vi_sion
print(hyphenator.hyphenateWord('subdivision'));

// ['sub', 'di', 'vi', 'sion']
print(hyphenator.syllablesWord('subdivision'));      
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

Internally, hyphenated as well as non-hyphenated words are cached. Complete texts are not cached.

**Hyphen symbol**

The hyphen symbol can be defined, the default is the soft-wrap `'\u{00AD}'`.

### Asynchronous Instantiation

Select the appropriate `Language.language_XX` value.

Or set a language code like `en_us`.

```dart
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';

final hyphernator = await Hyphenator.loadAsync(
    Language.language_en_us, 
    symbol: '_');

// OR THIS:

final hyphernator = await Hyphenator.loadAsyncByAbbr(
    'en_us', 
    symbol: '_');
```
list of valid letters of all western alphabets, including grave, acute, circumflex and all other letter variations.
### Synchronous Instantiation

Instatiate the appropriate `Language_XX()` object.

```dart 
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';

final config = Language_en_us();

final hyphenator = Hyphenator(
  config,
  symbol: '_',
);
```

### Widget Usage

This Widget outputs a `Text`. It hyphenates and wraps the input `String` depending on the available width. 

```dart 
import 'package:hyphenatorx/texthyphenated.dart';

TextHyphenated('subdivision', 
  'en_us',
  style: TextStyle(fontSize: 56))

// Wraps the output according to the available width:
// 
// sub-
// di-
// vi-
// sion
```

### Function Call

Inject the hyphenation symbol at all possible positions.

```dart
final hyphenator = Hyphenator(Language_en_us());

expect(
  hyphenator.hyphenateText('subdivision subdivision', 
    hyphenAtBoundaries: true), 
  'sub_di_vi_sion_ _sub_di_vi_sion');

expect(
  hyphenator.hyphenateText('subdivision subdivision'), 
  'sub_di_vi_sion sub_di_vi_sion');

expect(
  hyphenator.hyphenateWord('subdivision'),
  'sub_di_vi_sion');

expect(
  hyphenator.syllablesWord('subdivision'),
  ['sub', 'di', 'vi', 'sion']);      
```

Access the wrapped hyphenation result respecting the given width.

```dart
final hyphenator = Hyphenator(Language_en_us());

WrapResult wrap = hyphenator.wrap(
  final Text text, final TextStyle style, final maxWidth);

// The hyphenated text with hyphens and newlines:
// 
// sub-
// di-
// vi-
// sion- 
print( wrap.textStr ); 

// Whether the returned text is equal to 
// or smaller than maxWidth. 
//
// If FALSE, try a different font size.

print( wrap.isSizeMatching );  
```

### Manual Hyphenation 

Iterate through the token tree for a custom approach of hyphenation. Before and after each token a valid hyphen could be added. 

```dart
final text = """A vast subdivision of culture, 
    composed of many creative endeavors and disciplines.""";

final hyphenator = Hyphenator(Language_en_us());
final List<TextPartToken> tokens = hyphenator.hyphenateTextToTokens(text);

tokens.forEach((part) {
  if (part is NewlineToken) {
    print(part.text); // = is always a single newline
  } else if (part is TabsAndSpacesToken) {
    print(part.text); // tabs and spaces found in `text`
  } else if (part is WordToken) {
    part.parts.forEach((syllableAndSurrounding) {
      print(syllableAndSurrounding.text); // sub / di / vi / sion.
    });
  }
});

// A
// vast
// sub
// di
// vi
// sion
```

## Languages and Abbreviations

The abbreviations correspond with the `tex` file names found at [tug.org](https://tug.org/tex-hyphen/).

### Strings 

```dart
List<String> abbr = Hyphenator.languageAbbr();

print(abbr); 

// [af, as, bg, bn, ca, .., zh_latn_pinyin]
```

### Enum

As Islandic is been abbreviated "is", which is a Dart keyword, the prefix "language" had been added.

```dart 
enum Language { language_af,language_as,language_bg,language_bn,
language_ca,language_cop,language_cs,language_cy,language_da,
language_de_1901,language_de_1996,language_de_ch_1901,
language_el_monoton,language_el_polyton,language_en_gb
language_en_us,language_eo,language_es,language_et,
language_eu,language_fi,language_fr,language_fur,language_ga,
language_gl,language_grc,language_gu,language_hi,language_hr,
language_hsb,language_hu,language_hy,language_ia,language_id,
language_is,language_it,language_ka,language_kmr,language_kn,
language_la_x_classic,language_la,language_lt,language_lv,
language_ml,language_mn_cyrl_x_lmc,language_mn_cyrl,language_mr,
language_mul_ethi,language_nb,language_nl,language_nn,
language_or,language_pa,language_pl,language_pms,language_pt,
language_rm,language_ro,language_ru,language_sa,language_sh_cyrl,
language_sk,language_sl,language_sv,language_ta,language_te,
language_th,language_tk,language_tr,language_uk,
language_zh_latn_pinyin }
```

## Performance

Old machine:

* Instantiation via Dart EN_US file: 30 milliseconds
* Hyphenating text with 258 words: 46-56 milliseconds

Internal is-letter-testing impacts performance the most. At the moment, a binary search is performed over a combined set of (complete?) alphabets from various languages, plus an extra check for languages not included. Not terrible efficient, needs improvement.

## Generate JSON and Dart files

```shell
dart run ./tool/tex2dart.dart
```

The tool will delete `assets` and `lib/languages` before generating new files. It processes tex files located in `tool\tex\`.

## Source

This package is a copy and extension of [hyphenator](https://pub.dev/packages/hyphenator).


## Issues

Given this is a generic hyphenator, several issues are to be expected. Please open one at [Github](https://github.com/xErik/hyphenatorx/issues).