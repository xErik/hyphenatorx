# Hyphenator

Implementation of an hyphenation algorithm.

The `tex` patterns used in the algorithm can be found [here](https://tug.org/tex-hyphen/).

The package seems to work fine for western languages, other languages have to be evaluated.

A live Flutter demo can be found here: [https://xerik.github.io/hyphenatorx/](https://xerik.github.io/hyphenatorx/).

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

```dart
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';

final hyphernator = await Hyphenator.load(
    Language.language_en_us, 
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

Instatiate the appropriate `Language_XX` object.

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

## Performance

Old machine:

* Instantiation via Dart EN_US file: 30 milliseconds
* Hyphenating text with 258 words: 46 milliseconds

Internal testing whether a character is a letter has the most performance impact.

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

Possible performance improvement and general refactoring is TBD.