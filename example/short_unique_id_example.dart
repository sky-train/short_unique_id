import 'package:short_unique_id/short_unique_id.dart';

void main() {
  final uid = ShortUniqueId.alphanum();
  print(uid.stamp16());
}
