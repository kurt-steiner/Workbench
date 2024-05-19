import 'dart:math';

import 'package:frontend/model/enumeration.dart';

final _random = Random();

FlatUIColor randomColor() {
  int index = _random.nextInt(FlatUIColor.values.length);
  return FlatUIColor.values[index];
}