# Hyphenator

Implementation of an hyphenation algorithm.

The patterns used in the algorithm can be found [here](https://tug.org/tex-hyphen/).

## Install

`flutter pub add hyphenatorx`

## Usage

```dart 

final resource = await DefaultResourceLoader.load(
    DefaultResourceLoaderLanguage.enUs
  );

final hyphenator = Hyphenator(
    resource: resource,
    hyphenateSymbol:'_'
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

I will have a look at possible performance improvements. 