import 'package:flutter/material.dart';

extension HexColor on Color {
  static Color fromRGBHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write("ff");
    }


    buffer.write(hexString.substring(1));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension ToIsoString on DateTime {
  String toIsoString() {
    return "${year}-${month.toString().padLeft(2, "0")}-${day.toString().padLeft(2, "0")}";
  }
}