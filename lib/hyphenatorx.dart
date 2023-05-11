import 'languages/languageconfig.dart';
import 'src/extensions.dart';
import 'src/pattern.dart';

const _startEndMarker = '.';

class Hyphenator {
  final List<Pattern> _patterns = [];
  final Map<String, List<int>> _exceptions = {};
  final String hyphenateSymbol;
  final int minWordLength;
  final int minLetterCount;

  Hyphenator(
    LanguageConfig config, {
    this.hyphenateSymbol = '\u{00AD}',
    this.minWordLength = 5,
    this.minLetterCount = 3,
  }) {
    assert(minWordLength > 0);

    this._patterns.addAll(config.data['pattern']
        .map<Pattern>((pattern) => Pattern(
            pattern['result'] as String, List<int>.from(pattern['levels'])))
        .toList()
      ..sort());

    this._exceptions.addEntries(
          (config.data['exception'] as Map<String, dynamic>)
              .entries
              .map((entry) => MapEntry(entry.key, List<int>.from(entry.value))),
        );
  }

  /// Hyphenates a string with spaces.
  String hyphenate(String text) {
    var currentWord = StringBuffer();
    var result = new StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final c = text[i];

      if (c.isLetter) {
        currentWord.write(c);
      } else {
        if (currentWord.length > 0) {
          result.write(hyphenateWord(currentWord.toString()));
          currentWord.clear();
        }
        result.write(c);
      }
    }

    result.write(hyphenateWord(currentWord.toString()));

    return result.toString();
  }

  /// Hyphenates a single word.
  String hyphenateWord(String inputWord) {
    if (_isNotNeedHyphenate(inputWord)) return inputWord;

    final word = inputWord.toLowerCase();

    List<int>? hyphenationMask;

    if (_exceptions.containsKey(word))
      hyphenationMask = _exceptions[word];
    else {
      final levels = _generateLevelsForWord(word);
      hyphenationMask = _hyphenatedMaskFromLevels(levels);
      _correctHyphenationMask(hyphenationMask);
    }

    return _hyphenateByMask(inputWord, hyphenationMask);
  }

  /// Hyphenates a string and returns a list of
  /// valid hyphenations.
  List<String> hyphenateWordToList(String inputWord) {
    if (_isNotNeedHyphenate(inputWord)) return <String>[inputWord];

    final word = inputWord.toLowerCase();

    List<int>? hyphenationMask;

    if (_exceptions.containsKey(word))
      hyphenationMask = _exceptions[word];
    else {
      final levels = _generateLevelsForWord(word);
      hyphenationMask = _hyphenatedMaskFromLevels(levels);
      _correctHyphenationMask(hyphenationMask);
    }

    return _hyphenateByMaskToList(inputWord, hyphenationMask);
  }

  List<int> _generateLevelsForWord(String word) {
    final wordString = '$_startEndMarker$word$_startEndMarker';

    final levels = List.filled(wordString.length, 0);

    for (int i = 0; i < wordString.length - 2; ++i) {
      int patternIndex = 0;

      for (int count = 1; count <= wordString.length - i; ++count) {
        var patternFromWord =
            Pattern.patternOnly(wordString.substring(i, i + count));

        if (patternFromWord.compareTo(_patterns[patternIndex]) < 0) continue;

        patternIndex = _patterns.indexWhere(
          (pattern) => pattern.compareTo(patternFromWord) > 0,
          patternIndex,
        );

        if (patternIndex == -1) break;

        if (patternFromWord.compareTo(_patterns[patternIndex]) >= 0)
          for (int levelIndex = 0;
              levelIndex < _patterns[patternIndex].levelsCount - 1;
              ++levelIndex) {
            int level = _patterns[patternIndex].levelByIndex(levelIndex);

            if (level > levels[i + levelIndex]) levels[i + levelIndex] = level;
          }
      }
    }
    return levels;
  }

  List<int> _hyphenatedMaskFromLevels(List<int> levels) {
    int length = levels.length - 2;

    final hyphenationMask = List<int>.filled(length, 0);
    hyphenationMask[0] = 0;

    for (int i = 1; i < length; i++) {
      if (levels[i + 1] % 2 != 0) hyphenationMask[i] = 1;
    }

    return hyphenationMask;
  }

  void _correctHyphenationMask(List<int> mask) {
    if (mask.length > minLetterCount) {
      for (int i = 0; i < minLetterCount; i++) {
        mask[i] = 0;
      }

      final correctionLength = minLetterCount > 0 ? minLetterCount - 1 : 0;

      for (int i = mask.length - correctionLength; i < mask.length; i++) {
        mask[i] = 0;
      }
    } else {
      for (int i = 0; i < mask.length; i++) {
        mask[i] = 0;
      }
    }
  }

  String _hyphenateByMask(String word, List<int>? mask) {
    var result = StringBuffer();
    for (int i = 0; i < word.length; i++) {
      if (mask![i] > 0) result.write(hyphenateSymbol);
      result.write(word[i]);
    }
    return result.toString();
  }

  List<String> _hyphenateByMaskToList(String word, List<int>? mask) {
    StringBuffer currentSyllable = StringBuffer();
    List<String> returnList = <String>[];

    for (int i = 0; i < word.length; i++) {
      if (mask![i] > 0) {
        returnList.add(currentSyllable.toString());
        currentSyllable.clear();
      }
      currentSyllable.write(word[i]);
    }

    returnList.add(currentSyllable.toString());
    return returnList;
  }

  bool _isNotNeedHyphenate(String input) => input.length < minWordLength;
}
