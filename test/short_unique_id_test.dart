import 'package:short_unique_id/short_unique_id.dart';
import 'package:test/test.dart';

void main() {
  group('ShortUniqueId group of tests', () {

    test('ability to generate random id\'s of different lengths', () {
      final uid = ShortUniqueId.alphanum();
      final uidCollection = <String>[];

      uidCollection.add(uid.rnd(6));
      uidCollection.add(uid.rnd(7));
      uidCollection.add(uid.rnd(10));

      print(uidCollection);

      assert(uidCollection[0].length == 6);
      assert(uidCollection[1].length == 7);
      assert(uidCollection[2].length == 10);

      assert(uidCollection[0] != uidCollection[1]);
      assert(uidCollection[0] != uidCollection[2]);
      assert(uidCollection[1] != uidCollection[0]);
      assert(uidCollection[1] != uidCollection[2]);
      assert(uidCollection[2] != uidCollection[0]);
      assert(uidCollection[2] != uidCollection[1]);
    });

    test('ability to generate consecutive id\'s based on internal counter', () {
      final uid = ShortUniqueId.custom(['v', '0', 'Y']);

      var result = uid.seq();
      print(result);
      assert(result == 'v');

      result = uid.seq();
      print(result);
      assert(result == '0');

      result = uid.seq();
      print(result);
      assert(result == 'Y');
    });

    test('ability to be instantiated with default dictionaries', () {
      final number = ShortUniqueId(SUIDictionaries.number, shuffle: false);
      print(number.dict.join());
      assert([number.seq(), number.seq()].join('') == '01');

      final alpha = ShortUniqueId(SUIDictionaries.alpha, shuffle: false);
      print(alpha.dict.join());
      assert([alpha.seq(), alpha.seq()].join('') == 'ab');
      assert([...alpha.dict][alpha.dict.length - 1] == 'Z');

      final alphaLower = ShortUniqueId(SUIDictionaries.alphaLower, shuffle: false);
      print(alphaLower.dict.join());
      assert([...alphaLower.dict][alphaLower.dict.length - 1] == 'z');

      final alphaUpper = ShortUniqueId(SUIDictionaries.alphaUpper, shuffle: false);
      print(alphaUpper.dict.join());
      assert([alphaUpper.seq(), alphaUpper.seq()].join('') == 'AB');

      final alphanum = ShortUniqueId(SUIDictionaries.alphanum, shuffle: false);
      print(alphanum.dict.join());
      assert([alphanum.seq(), alphanum.seq()].join('') == '01');
      assert([...alphanum.dict][alphanum.dict.length - 1] == 'Z');

      final alphanumLower = ShortUniqueId(SUIDictionaries.alphanumLower, shuffle: false);
      print(alphanumLower.dict.join());
      assert([alphanumLower.seq(), alphanumLower.seq()].join('') == '01');
      assert([...alphanumLower.dict][alphanumLower.dict.length - 1] == 'z');

      final alphanumUpper = ShortUniqueId(SUIDictionaries.alphanumUpper, shuffle: false);
      print(alphanumUpper.dict.join());
      assert([alphanumUpper.seq(), alphanumUpper.seq()].join('') == '01');
      assert([...alphanumUpper.dict][alphanumUpper.dict.length - 1] == 'Z');

      final hex = ShortUniqueId(SUIDictionaries.hex, shuffle: false);
      print(hex.dict.join());
      assert([
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
            hex.seq(),
          ].join('') ==
          '0123456789abcdef');

      final hex2 = ShortUniqueId(SUIDictionaries.hex);
      final result = hex2.rnd(3);
      print(result);
      assert(RegExp(r'^[0123456789abcdef][0123456789abcdef][0123456789abcdef]$').hasMatch(result));
    });

    test('ability to be instantiated with user-defined dictionary', () {
      final uid = ShortUniqueId.custom(['a', '1'], shuffle: false, length: 2);
      assert(RegExp(r'^[a1][a1]$').hasMatch(uid.rnd()));
      final result = [uid.seq(), uid.seq()].join('');
      print(result);
      assert(result == 'a1');
    });

    test('ability to skip shuffle when instantiated', () {
      final uid = ShortUniqueId.alphanum(shuffle: false);

      var result = uid.seq();
      print(result);
      assert(result == '0');

      result = uid.seq();
      print(result);
      assert(result == '1');
    });

    test('ability to calculate total number of possible UUIDs', () {
      final totals = <num>[];

      final uid = ShortUniqueId.alphanum();
      totals.add(uid.availableUUIDs());

      final uid2 = ShortUniqueId.custom(['a', 'b']);
      totals.add(uid2.availableUUIDs());

      final uid3 = ShortUniqueId.custom(['a', 'b', 'b', 'a']);
      totals.add(uid3.availableUUIDs());

      final lengthOfTwo = 2;
      totals.add(uid3.availableUUIDs(lengthOfTwo));

      print(totals);

      /* tslint:disable no-magic-numbers */
      assert(totals[0] == 56800235584); // 62^6
      assert(totals[1] == 64); // 2^6
      assert(totals[2] == 64); // 2^6
      assert(totals[3] == 4); // 2^2
    });

    test('ability to calculate probability of collision given number of UUID generation rounds', () {
      final totals = <num>[];
      final uid = ShortUniqueId.alphanum();

      /* tslint:disable no-magic-numbers */
      totals.add(uid.collisionProbability());
      totals.add(uid.collisionProbability(1000000));

      final uid2 = ShortUniqueId.custom(['a', 'b']);
      totals.add(uid2.collisionProbability(1, 1));

      final uid3 = ShortUniqueId.custom(['a', 'b', 'b', 'a']);
      totals.add(uid3.collisionProbability(1, 1));

      print(totals);

      assert(totals[0] == 0.00000525877839496618); // sqrt((pi/2)*(62^6))/(62^6)
      assert(totals[1] == 0.00000002206529822331); // sqrt((pi/2)*1000000)/(62^6)
      assert(totals[2] == 0.6266570686577501); // sqrt(pi/2)/(2)
      assert(totals[3] == 0.6266570686577501); // sqrt(pi/2)/(2)
    });

    test('ability to calculate approx. num. of hashes before first collision', () {
      final totals = <num>[];
      final uid = ShortUniqueId.alphanum();

      totals.add(uid.approxMaxBeforeCollision());

      final uid2 = ShortUniqueId.custom(['a', 'b']);
      totals.add(uid2.approxMaxBeforeCollision());

      final uid3 = ShortUniqueId.custom(['a', 'b', 'b', 'a']);
      totals.add(uid3.approxMaxBeforeCollision());

      print(totals);

      /* tslint:disable no-magic-numbers */
      assert(totals[0] == 298699.85171812854); // sqrt((pi/2)*(62^6))
      assert(totals[1] == 10.026513098524001); // sqrt((pi/2)*(2^6))
      assert(totals[2] == 10.026513098524001); // sqrt((pi/2)*(2^6))
    });

    test('ability to calculate "uniqueness" score of UUIDs based on size of dictionary and chosen UUID length', () {
      final totals = <num>[];
      final uid = ShortUniqueId.alphanum();

      totals.add(uid.uniqueness());
      final millionPossibleRounds = 1000000;
      totals.add(uid.uniqueness(millionPossibleRounds));

      final uid2 = ShortUniqueId.custom(['a', 'a']);
      totals.add(uid2.uniqueness());

      final uid3 = ShortUniqueId.custom(['a', 'a', 'a', 'a']);
      totals.add(uid3.uniqueness());

      final twoPossibleRounds = 2;
      final uid4 = ShortUniqueId.custom(['a', 'b']);
      totals.add(uid4.uniqueness(twoPossibleRounds));
      final uid5 = ShortUniqueId.custom(['a', 'b', 'b', 'a']);
      totals.add(uid5.uniqueness(twoPossibleRounds));

      print(totals);

      /* tslint:disable no-magic-numbers */
      assert(totals[0] == 0.999994741221605); // 1 - (sqrt((pi/2)*(62^6)) / (62^6))
      assert(totals[1] == 0.9987466858626844); // 1 - (sqrt((pi/2)*1000000) / (62^6))
      assert(totals[2] == 0);
      assert(totals[3] == 0);
      assert(totals[4] == 0.11377307454724206);
      assert(totals[5] == 0.11377307454724206);
    });

    test('ability to generate UUIDs that include an extractable timestamp', () {
      final uid = ShortUniqueId.alphanum();
      final nowTenStamp =
          int.parse((DateTime.now().millisecondsSinceEpoch / 1000).floor().toRadixString(16), radix: 16) * 1000;
      final tenStamp = uid.stamp(10);
      print(tenStamp);
      assert(tenStamp.length == 10);

      final parsedTenStamp = uid.parseStamp(tenStamp).millisecondsSinceEpoch;
      print('$parsedTenStamp, $nowTenStamp');
      assert(parsedTenStamp == nowTenStamp);

      final pastDate = DateTime.utc(2020, 4, 24);

      final nowOmniStamp =
          int.parse((pastDate.millisecondsSinceEpoch / 1000).floor().toRadixString(16), radix: 16) * 1000;
      final omniStamp = uid.stamp(42, pastDate);
      print(omniStamp);
      assert(omniStamp.length == 42);

      final parsedOmniStamp = uid.parseStamp(omniStamp).millisecondsSinceEpoch;
      print('$parsedOmniStamp, $nowOmniStamp');
      assert(parsedOmniStamp == nowOmniStamp);

      final isoOmniStamp = (DateTime.fromMillisecondsSinceEpoch(parsedOmniStamp, isUtc: true)).toIso8601String();
      print(isoOmniStamp);
      assert(isoOmniStamp == '2020-04-24T00:00:00.000Z');
    });

    test('ability to create custom formatted UUID', () {
      final uid = ShortUniqueId.custom(['a', 'b'], shuffle: false);

      var testRegex = RegExp(r'[0-9abcdef]{11}[0-3]-a-[ab]{2}');
      var result = uid.fmt('\$t12-\$s0-\$r2');

      print(result);
      assert(testRegex.hasMatch(result));

      testRegex = RegExp('Time: ${uid.stamp(0)} ID: 0b-[ab]{4}');
      result = uid.fmt('Time: \$t0 ID: \$s2-\$r4');

      print(result);
      assert(testRegex.hasMatch(result));

      final timestamp = DateTime.utc(2023, 01, 29, 3, 21, 21);
      testRegex = RegExp('Time: ${uid.stamp(0, timestamp)} ID: ab-[ab]{4}');
      result = uid.fmt('Time: \$t0 ID: \$s2-\$r4', timestamp);

      print(result);
      assert(testRegex.hasMatch(result));
    });

    test('ability to create custom formatted UUID with an extractable timestamp', () {
      final uid = ShortUniqueId.custom(['a', 'b'], shuffle: false);

      final timestamp = DateTime.utc(2023, 01, 29, 03, 21, 21);
      final nowStamp = int.parse((timestamp.millisecondsSinceEpoch / 1000).floor().toRadixString(16), radix: 16) * 1000;
      final format = '\$r2-\$t12-\$s2';
      final result = uid.fmt(format, timestamp);
      print(result);

      final parsedStamp = uid.parseStamp(result, format).millisecondsSinceEpoch;
      print(parsedStamp);
      assert(parsedStamp == nowStamp);
    });
  });
}
