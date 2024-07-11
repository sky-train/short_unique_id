import 'package:short_unique_id/short_unique_id.dart';
final short = ShortUniqueId.alphanum(length: 9);

uid() {
  return 't${short.rnd()}';
}


main() {
  var data = <String>[];
  var uData = <String>{};

  for (int i = 0; i < 100000; i++) {
    var id = uid();
    print(id);
    data.add(id);
    uData.add(id);
  }

  print(data.length);
  print(uData.length);
}
