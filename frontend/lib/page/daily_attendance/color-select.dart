import 'package:flutter/material.dart';
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/settings.dart';

class ColorSelect extends StatelessWidget {
  static FlatUIColor get defaultColor => FlatUIColor.values.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            dailyAttendanceNavigationKey.currentState!.pop(null);
          },
        ),
      ),

      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      childAspectRatio: 1,
      children: FlatUIColor.values.map<Widget>((color) => InkWell(
        onTap: () {
          dailyAttendanceNavigationKey.currentState!.pop(color);
        },

        child: Container(
          color: flatUIColors[color]!,
          child: Center(
            child: Text(color.toEnumString(), style: const TextStyle(color: Colors.white),),
          ),
        ),
      )).toList()

    );
  }
}