## 1.0.0

- Initial clone, adjustments for Dart 3.

## 1.0.1

- pub.dev analysis trouble.

## 1.1.0

- Synchronous and asynchronous loading of language data.

## 1.1.1

- Added cache for hypenated and non-hyphenated words.
- Added live demo.

## 1.1.2

- Bugfix concerning caching of hyphenation-as-lists function.

## 1.1.3

- Improved performance of method `hyphenate( )` by ~15 % for non-cached invocations.

## 1.2.0

- Added widget `TextHyphenated`.
- Renamed `symbol` and `lang` parameters.

## 1.3.0

- Renamed `hyphenateWordToList()` to `syllablesWord()`.
- Renamed `hyphenate()` to `hyphenateText()`: Hyphenates words only, not word boundaries.
- Added `hyphenateTextAndBoundaries()`: Injecting additional hyphens at word boundaries, surrounding chars becomming part of a "word".

## 1.4.0

- Removed `hyphenateTextAndBoundaries()`.
- Added `hyphenateTextToTokens()`: Returns a tree of tokens inducating possible hyphenation.

## 1.5.0

- Added `WrapResult wrap()`: Returns a hyphenation result for a given width.
- Added Hyphenation Widget.

## 1.5.1

- Bugfix.

## 1.5.2

- Performance `hyphenateText()`.

## 1.5.3

- Quality: checking letters of various alphabets (but alphabets may be incomplete).

## 1.5.4

- Bugfix: Word too big for `wrap()`.

## 1.5.5

- Unit Tests.
