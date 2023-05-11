# Hyphenator

Implementation of an hyphenation algorithm.

The patterns used in the algorithm can be found [here](https://tug.org/tex-hyphen/).

it seems to work fine for western languages, other languages have to be evaluated.

## Installation

```shell
flutter pub add hyphenatorx
```

## Usage

Hyphenator instantiates a language specific configuration:

**As a Dart object**: Without synchronous loading. The data is compiled into your project. All 71 langauge files together have a size of 13.3 MB.
  
**From JSON**: With asynchronous loading. The data will be loaded as needed. This option is less memory intense.

Available languages are given by the `enum Language`.

### Asynchronous Instantiation

For asynchronous operation select the appropriate `Language.language_XX` value.

```dart
import 'package:hyphenatorx/hyphenatorx.dart';
import 'package:hyphenatorx/languages/language_en_us.dart';
import 'package:hyphenatorx/languages/languageconfig.dart';

final hyphernator = await Hyphenator.load(
    Language.language_en_us, 
    hyphenateSymbol: '_'
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

### Synchronous Instantiation

For synchronous operation instatiate the appropriate `Language_XX` object.

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

## Source

This package is a copy of [hyphenator](https://pub.dev/packages/hyphenator).

This package has been updated to Dart 3.

I will have a look at a possible performance improvement and general refactoring.