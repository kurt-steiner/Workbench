import 'package:flutter/material.dart';
import 'package:frontend/settings.dart';

class WeekdaysCheckbox extends StatefulWidget {
  static final weekdays0 = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"];
  static final weekdays1 = ["一", "二", "三", "四", "五", "六", "日"];

  List<String> weekdays;
  void Function(List<String>) onChanged;

  WeekdaysCheckbox({required this.onChanged, required this.weekdays});

  @override
  _WeekdaysCheckboxState createState() => _WeekdaysCheckboxState();
}

class _WeekdaysCheckboxState extends State<WeekdaysCheckbox> {
  late List<bool> flags;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flags = WeekdaysCheckbox.weekdays0.map<bool>((e) => widget.weekdays.contains(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: WeekdaysCheckbox.weekdays0.indexed.map<Widget>((e) => buildItem(context, e.$1)).toList(),
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          flags[index] = !flags[index];
        });

        List<String> weekdays = WeekdaysCheckbox.weekdays0.indexed.where((element) => flags[element.$1]).map((element) => element.$2).toList();
        widget.onChanged(weekdays);
      },

      child: Container(
        margin: dailyAttendanceSettings["widget.daily-attendance.checkbox.margin"],
        padding: dailyAttendanceSettings["widget.daily-attendance.checkbox.padding"],
        decoration: BoxDecoration(
          color: flags[index] ? Colors.blue : const Color.fromRGBO(0, 0, 0, 0.1),
          shape: BoxShape.circle
        ),

        child: Text(WeekdaysCheckbox.weekdays1[index], style: TextStyle(color: flags[index] ? Colors.white : Colors.black),),
      ),
    );
  }
}