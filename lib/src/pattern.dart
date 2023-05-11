class Pattern implements Comparable<Pattern> {
  final String _pattern;
  final List<int> _levels;

  Pattern(this._pattern, this._levels);

  Pattern.patternOnly(this._pattern) : _levels = const [];

  int get levelsCount => _levels.length;

  int levelByIndex(int index) => _levels[index];

  @override
  String toString() => 'Pattern: pattern: $_pattern, levels: $_levels';

  @override
  int compareTo(Pattern other) {
    bool first = _pattern.length < other._pattern.length;
    int minSize = first ? _pattern.length : other._pattern.length;

    for (var i = 0; i < minSize; ++i) {
      final res = _pattern[i].compareTo(other._pattern[i]);
      if (res != 0) return res;
    }
    return first ? -1 : 1;
  }
}
