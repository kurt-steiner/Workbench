import 'dart:math';

import 'package:frontend/model/enumeration.dart';

final _random = Random();

TagColor randomColor() {
  int index = _random.nextInt(TagColor.values.length);
  return TagColor.values[index];
}