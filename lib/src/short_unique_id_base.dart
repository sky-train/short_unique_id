/// https://www.npmjs.com/package/short-unique-id?activeTab=readme
/// source

import 'dart:math';

const int defaultUuidLength = 6;
const int probability = 5;

enum SUIDictionaries { number, alpha, alphaLower, alphaUpper, alphanum, alphanumLower, alphanumUpper, hex }

class ShortUniqueId {
  static const int _hexLastAscii = 103;
  static const int _digitLastAscii = 58;
  static const int _digitFirstAscii = 48;
  static const int _alphaUpperLastAscii = 91;
  static const int _alphaLowerLastAscii = 123;
  static const int _alphaLowerFirstAscii = 97;
  static const int _alphaUpperFirstAscii = 65;

  static const Map<String, List<int>> _numberDictRanges = {
    'digits': [_digitFirstAscii, _digitLastAscii],
  };
  static const Map<String, List<int>> _alphaDictRanges = {
    'lowerCase': [_alphaLowerFirstAscii, _alphaLowerLastAscii],
    'upperCase': [_alphaUpperFirstAscii, _alphaUpperLastAscii],
  };
  static const Map<String, List<int>> _alphaLowerDictRanges = {
    'lowerCase': [_alphaLowerFirstAscii, _alphaLowerLastAscii],
  };
  static const Map<String, List<int>> _alphaUpperDictRanges = {
    'upperCase': [_alphaUpperFirstAscii, _alphaUpperLastAscii],
  };
  static const Map<String, List<int>> _alphanumDictRanges = {
    'digits': [_digitFirstAscii, _digitLastAscii],
    'lowerCase': [_alphaLowerFirstAscii, _alphaLowerLastAscii],
    'upperCase': [_alphaUpperFirstAscii, _alphaUpperLastAscii],
  };
  static const Map<String, List<int>> _alphanumLowerDictRanges = {
    'digits': [_digitFirstAscii, _digitLastAscii],
    'lowerCase': [_alphaLowerFirstAscii, _alphaLowerLastAscii],
  };
  static const Map<String, List<int>> _alphanumUpperDictRanges = {
    'digits': [_digitFirstAscii, _digitLastAscii],
    'upperCase': [_alphaUpperFirstAscii, _alphaUpperLastAscii],
  };
  static const Map<String, List<int>> _hexDictRanges = {
    'decDigits': [_digitFirstAscii, _digitLastAscii],
    'alphaDigits': [_alphaLowerFirstAscii, _hexLastAscii],
  };

  static const Map<SUIDictionaries, Map<String, List<int>>> _dictRanges = {
    SUIDictionaries.number: _numberDictRanges,
    SUIDictionaries.alpha: _alphaDictRanges,
    SUIDictionaries.alphaLower: _alphaLowerDictRanges,
    SUIDictionaries.alphaUpper: _alphaUpperDictRanges,
    SUIDictionaries.alphanum: _alphanumDictRanges,
    SUIDictionaries.alphanumLower: _alphanumLowerDictRanges,
    SUIDictionaries.alphanumUpper: _alphanumUpperDictRanges,
    SUIDictionaries.hex: _hexDictRanges,
  };

  final String _version = '1.0.0';

  int _counter = 0;
  int _dictIndex = 0;
  List<String> _dict = [];
  List<int> _dictRange = [];

  int _lowerBound = 0;
  int _upperBound = 0;
  int _dictLength = 0;
  int _uuidLength = defaultUuidLength;

  ShortUniqueId(
    SUIDictionaries dictionary, {
    bool? shuffle = true,
    int? length = defaultUuidLength,
    int? counter = 0,
  }) {
    _uuidLength = length ?? defaultUuidLength;
    _setDictionary(dictionary, shuffle);
    _counter = counter ?? 0;
  }

  ShortUniqueId.alphanum({
    bool? shuffle = true,
    int? length = defaultUuidLength,
    int? counter = 0,
  }) {
    _uuidLength = length ?? defaultUuidLength;
    _setDictionary(SUIDictionaries.alphanum, shuffle);
    _counter = counter ?? 0;
  }

  ShortUniqueId.custom(
    List<String> dictionary, {
    bool? shuffle,
    int? length,
    int? counter,
  }) {
    _uuidLength = length ?? defaultUuidLength;
    _setCustomDictionary(dictionary, shuffle);
    _counter = counter ?? 0;
  }

  /// Change the dictionary after initialization.
  void _setDictionary(SUIDictionaries dictionary, bool? shuffle) {
    int i = 0;
    _dictIndex = 0;
    List<String> finalDict = [];

    final ranges = _dictRanges[dictionary];
    for (final range in ranges!.values) {
      _dictRange = range;
      _lowerBound = _dictRange[0];
      _upperBound = _dictRange[1];

      for (_dictIndex = i = _lowerBound;
          _lowerBound <= _upperBound ? i < _upperBound : i > _upperBound;
          _dictIndex = _lowerBound <= _upperBound ? i += 1 : i -= 1) {
        finalDict.add(String.fromCharCode(_dictIndex));
      }
    }

    if (shuffle ?? false) {
      // Shuffle Dictionary to remove selection bias.
      finalDict.sort((a, b) => Random().nextInt(10) - probability);
    }

    _dict = finalDict;
    _dictLength = _dict.length;
    _counter = 0;
  }

  void _setCustomDictionary(List<String> dictionary, bool? shuffle) {
    if (dictionary.length <= 1) {
      throw Exception('dictionary length must be more 1');
    }

    List<String> finalDict = dictionary;
    if (shuffle ?? false) {
      // Shuffle Dictionary to remove selection bias.
      finalDict.sort((a, b) => Random().nextInt(10) - probability);
    }

    _dict = finalDict;
    _dictLength = _dict.length;
    _counter = 0;
  }

  String seq() {
    return sequentialUUID();
  }

  /// Generates UUID based on internal counter that's incremented after each ID generation.
  /// @alias `const uid = new ShortUniqueId(); uid.seq();`
  String sequentialUUID() {
    int counterDiv;
    int counterRem;
    String id = '';
    counterDiv = _counter;
    do {
      counterRem = counterDiv % _dictLength;
      counterDiv = (counterDiv / _dictLength).truncate();
      id += _dict[counterRem];
    } while (counterDiv != 0);
    _counter += 1;
    return id;
  }

  String rnd([int? length]) {
    return randomUUID(length ?? _uuidLength);
  }

  /// Generates UUID by creating each part randomly.
  /// @alias `const uid = new ShortUniqueId(); uid.rnd(uuidLength: number);`
  String randomUUID([int? length]) {
    length = length ?? _uuidLength;
    if (length < 1) {
      throw Exception('Invalid UUID Length Provided');
    }
    String id = '';

    // Generate random ID parts from Dictionary.
    for (int j = 0; j < length; j += 1) {
      int randomPartIdx = Random().nextInt(_dictLength) % _dictLength;
      id += _dict[randomPartIdx];
    }
    // Return random generated ID.
    return id;
  }

  String fmt(String format, [DateTime? date]) {
    return formattedUUID(format, date);
  }

  /// Generates custom UUID with the provided format string.
  /// @alias `const uid = new ShortUniqueId(); uid.fmt(format: string);`
  String formattedUUID(String format, [DateTime? date]) {
    final fnMap = {
      '\$r': randomUUID,
      '\$s': sequentialUUID,
      '\$t': stamp,
    };
    final result = format.replaceAllMapped(RegExp(r'\$[rs]\d{0,}|\$t0|\$t[1-9]\d{1,}'), (match) {
      String m = match[0]!;
      final fn = m.substring(0, 2);
      final len = int.parse(m.substring(2));
      if (fn == '\$s') {
        return fnMap[fn]!().padLeft(len, '0');
      }

      if (fn == '\$t' && date != null) {
        return fnMap[fn]!(len, date);
      }

      return fnMap[fn]!(len);
    });

    return result;
  }

  /// Generates a UUID with a timestamp that can be extracted using `uid.parseStamp(stampString);`.
  ///
  /// ```js
  ///  const uidWithTimestamp = uid.stamp(32);
  ///  console.log(uidWithTimestamp);
  ///  // GDa608f973aRCHLXQYPTbKDbjDeVsSb3
  ///
  ///  console.log(uid.parseStamp(uidWithTimestamp));
  ///  // 2021-05-03T06:24:58.000Z
  ///  ```
  String stamp(int finalLength, [DateTime? date]) {
    final hexStamp = ((date ?? DateTime.now()).millisecondsSinceEpoch / 1000).floor().toRadixString(16);

    if (finalLength == 0) {
      return hexStamp;
    }

    if (finalLength < 10) {
      throw Exception([
        'Param finalLength must be a number greater than or equal to 10,',
        'or 0 if you want the raw hexadecimal timestamp',
      ].join('\n'));
    }

    final idLength = finalLength - 9;
    final rndIdx = Random().nextInt(((idLength > 15) ? 15 : idLength));
    final id = randomUUID(idLength);
    return '${id.substring(0, rndIdx)}$hexStamp${id.substring(rndIdx)}${rndIdx.toRadixString(16)}';
  }

  String stamp16() {
    return stamp(16);
  }

  /// Extracts the date embeded in a UUID generated using the `uid.stamp(finalLength);` method.
  ///
  /// ```js
  ///  const uidWithTimestamp = uid.stamp(32);
  ///  console.log(uidWithTimestamp);
  ///  // GDa608f973aRCHLXQYPTbKDbjDeVsSb3
  ///
  ///  console.log(uid.parseStamp(uidWithTimestamp));
  ///  // 2021-05-03T06:24:58.000Z
  ///  ```
  DateTime parseStamp(String suid, [String? format]) {
    if (format != null && !(RegExp(r't0|t[1-9]\d{1,}').hasMatch(format))) {
      throw Exception('Cannot extract date from a formatted UUID with no timestamp in the format');
    }

    String stamp = '';

    if (format != null) {
      final fnMap = {
        '\$r': (int len) => 'r' * len,
        '\$s': (int len) => 's' * len,
        '\$t': (int len) => 't' * len,
      };
      stamp = format.replaceAllMapped(RegExp(r'\$[rs]\d{0,}|\$t0|\$t[1-9]\d{1,}'), (match) {
        final m = match[0]!;
        final fn = m.substring(0, 2);
        final len = int.parse(m.substring(2), radix: 10);

        return fnMap[fn]!(len);
      }).replaceAllMapped(RegExp(r'^(.*?)(t{8,})(.*)$'), (match) {
         return suid.substring(match[1]!.length, match[1]!.length + match[2]!.length);
      });
    } else {
      stamp = suid;
    }

    if (stamp.length == 8) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(stamp, radix: 16) * 1000);
    }

    if (stamp.length < 10) {
      throw Exception('Stamp length invalid');
    }

    final rndIdx = int.parse(stamp.substring(stamp.length - 1), radix: 16);
    return DateTime.fromMillisecondsSinceEpoch(int.parse(stamp.substring(rndIdx, rndIdx + 8), radix: 16) * 1000);
  }

  /// Calculates total number of possible UUIDs.
  ///
  /// Given that:
  ///
  /// - `H` is the total number of possible UUIDs
  /// - `n` is the number of unique characters in the dictionary
  /// - `l` is the UUID length
  ///
  /// Then `H` is defined as `n` to the power of `l`:
  ///
  /// <div style="background: white; padding: 5px; border-radius: 5px; overflow: hidden;">
  ///  <img src="https://render.githubusercontent.com/render/math?math=%5CHuge%20H=n%5El"/>
  /// </div>
  ///
  /// This function returns `H`.
  int availableUUIDs([int? length]) {
    return pow(Set.from(_dict).length, length ?? _uuidLength).round();
  }

  /// Calculates approximate number of hashes before first collision.
  ///
  /// Given that:
  ///
  /// - `H` is the total number of possible UUIDs, or in terms of this library,
  /// the result of running `availableUUIDs()`
  /// - the expected number of values we have to choose before finding the
  /// first collision can be expressed as the quantity `Q(H)`
  ///
  /// Then `Q(H)` can be approximated as the square root of the product of half
  /// of pi times `H`:
  ///
  /// <div style="background: white; padding: 5px; border-radius: 5px; overflow: hidden;">
  ///  <img src="https://render.githubusercontent.com/render/math?math=%5CHuge%20Q(H)%5Capprox%5Csqrt%7B%5Cfrac%7B%5Cpi%7D%7B2%7DH%7D"/>
  /// </div>
  ///
  /// This function returns `Q(H)`.
  ///
  /// (see [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution))
  num approxMaxBeforeCollision([int? rounds]) {
    rounds = rounds ?? availableUUIDs(_uuidLength);
    return double.parse(sqrt((pi / 2) * rounds).toStringAsFixed(20));
  }

  /// Calculates probability of generating duplicate UUIDs (a collision) in a
  /// given number of UUID generation rounds.
  ///
  /// Given that:
  ///
  /// - `r` is the maximum number of times that `randomUUID()` will be called,
  /// or better said the number of _rounds_
  /// - `H` is the total number of possible UUIDs, or in terms of this library,
  /// the result of running `availableUUIDs()`
  ///
  /// Then the probability of collision `p(r; H)` can be approximated as the result
  /// of dividing the square root of the product of half of pi times `r` by `H`:
  ///
  /// <div style="background: white; padding: 5px; border-radius: 5px; overflow: hidden;">
  ///  <img src="https://render.githubusercontent.com/render/math?math=%5CHuge%20p(r%3B%20H)%5Capprox%5Cfrac%7B%5Csqrt%7B%5Cfrac%7B%5Cpi%7D%7B2%7Dr%7D%7D%7BH%7D"/>
  /// </div>
  ///
  /// This function returns `p(r; H)`.
  ///
  /// (see [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution))
  ///
  /// (Useful if you are wondering _"If I use this lib and expect to perform at most
  /// `r` rounds of UUID generations, what is the probability that I will hit a duplicate UUID?"_.)
  num collisionProbability([int? rounds, int? length]) {
    // ? why for rounds using  _uuidLength
    rounds = rounds ?? availableUUIDs(_uuidLength);
    length = length ?? _uuidLength;
    return double.parse((approxMaxBeforeCollision(rounds) / availableUUIDs(length)).toStringAsFixed(20));
  }

  /// Calculate a "uniqueness" score (from 0 to 1) of UUIDs based on size of
  /// dictionary and chosen UUID length.
  ///
  /// Given that:
  ///
  /// - `H` is the total number of possible UUIDs, or in terms of this library,
  /// the result of running `availableUUIDs()`
  /// - `Q(H)` is the approximate number of hashes before first collision,
  /// or in terms of this library, the result of running `approxMaxBeforeCollision()`
  ///
  /// Then `uniqueness` can be expressed as the additive inverse of the probability of
  /// generating a "word" I had previously generated (a duplicate) at any given iteration
  /// up to the the total number of possible UUIDs expressed as the quotiend of `Q(H)` and `H`:
  ///
  /// <div style="background: white; padding: 5px; border-radius: 5px; overflow: hidden;">
  ///  <img src="https://render.githubusercontent.com/render/math?math=%5CHuge%201-%5Cfrac%7BQ(H)%7D%7BH%7D"/>
  /// </div>
  ///
  /// (Useful if you need a value to rate the "quality" of the combination of given dictionary
  /// and UUID length. The closer to 1, higher the uniqueness and thus better the quality.)
  num uniqueness([int? rounds]) {
    rounds = rounds ?? availableUUIDs(_uuidLength);
    final score = double.parse((1 - (approxMaxBeforeCollision(rounds) / rounds)).toStringAsFixed(20));
    return (score > 1) ? (1) : ((score < 0) ? 0 : score);
  }

  /// Return the version of this module.
  String get version {
    return _version;
  }

  int get counter {
    return _counter;
  }

  Iterable<String> get dict {
    return _dict.take(_dict.length);
  }
}
