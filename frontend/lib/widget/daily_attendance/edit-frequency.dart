import 'package:flutter/material.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/widget/daily_attendance/weekdays-checkbox.dart';
import 'package:numberpicker/numberpicker.dart';

class TaskEditFrequency extends StatefulWidget {
  PostTaskRequest? postRequest;
  UpdateTaskRequest? updateRequest;
  TaskEditFrequency({this.postRequest, this.updateRequest});

  dynamic get request => postRequest ?? updateRequest;

  @override
  _TaskEditFrequencyState createState() => _TaskEditFrequencyState();
}

class _TaskEditFrequencyState extends State<TaskEditFrequency> with SingleTickerProviderStateMixin {
  late TabController controller;
  late int index;
  List<String> weekdays = [];
  int countInWeek = 1;
  int interval = 1;

  final tabs = const [
    Tab(text: "按天"),
    Tab(text: "按周"),
    Tab(text: "按时间间隔")
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);

    switch (widget.request.frequency.runtimeType) {
      case da.Days:
        controller.index = 0;
        break;
      case da.CountInWeek:
        controller.index = 1;
        break;
      default:
        controller.index = 2;
        break;
    }

    index = controller.index;
   }

   @override
  Widget build(BuildContext context) {
     final Widget tabBar = Align(
       alignment: Alignment.centerLeft,
       child: TabBar(
         controller: controller,
         tabs: tabs,
         isScrollable: true,
         indicatorSize: TabBarIndicatorSize.label,
         tabAlignment: TabAlignment.start,
         onTap: (index) {
           setState(() {
             this.index = index;
           });
         },
       ),
     );
     
     late Widget tabBody;
     switch (index) {
       case 0:
         tabBody = buildFrequencyDays(context);
         break;
       case 1:
         tabBody = buildFrequencyCountInWeek(context);
          break;
       case 2:
         tabBody = buildFrequencyInterval(context);
         break;
     }
     
     return Card(
       child: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           tabBar,
           tabBody
         ],
       ),
     );
  }

  Widget buildFrequencyDays(BuildContext context) {
    if (widget.request.frequency is da.Days) {
      weekdays = (widget.request.frequency as da.Days).weekdays;
    } else {
      weekdays = WeekdaysCheckbox.weekdays0;
    }

    return WeekdaysCheckbox(
        onChanged: (weekdays) {
          setState(() {
            this.weekdays = weekdays;
            widget.request.frequency = da.Days(weekdays: weekdays);
          });
        },

        weekdays: weekdays
    );
  }

  Widget buildFrequencyCountInWeek(BuildContext context) {
    if (widget.request.frequency is da.CountInWeek) {
      countInWeek = (widget.request.frequency as da.CountInWeek).count;
    } else {
      countInWeek = 1;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NumberPicker(
          value: countInWeek,
          minValue: 1,
          maxValue: 6,
          onChanged: (value) {
            setState(() {
              countInWeek = value;
              widget.request.frequency = da.CountInWeek(count: value);
            });
          },
        ),

        const Text("天每周")
      ],
    );
  }

  Widget buildFrequencyInterval(BuildContext context) {
    if (widget.request.frequency is da.Interval) {
      interval = (widget.request.frequency as da.Interval).count;
    } else {
      interval = 1;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("每"),
        NumberPicker(
          minValue: 1,
          maxValue: 30,
          value: interval,
          onChanged: (value) {
            setState(() {
              interval = value;
              widget.request.frequency = da.Interval(count: interval);
            });
          },
        ),

        const Text("天")
      ],
    );
  }
}