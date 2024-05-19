import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatefulWidget {
  static final weekDays = ["一", "二", "三", "四", "五", "六", "日"];
  static final weekDayDistance = {
    DateTime.monday: 0,
    DateTime.tuesday: 1,
    DateTime.wednesday: 2,
    DateTime.thursday: 3,
    DateTime.friday: 4,
    DateTime.saturday: 5,
    DateTime.sunday: 6
  };

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with StateMixin, SingleTickerProviderStateMixin {
  int offsetWeek = 0;
  int offsetMonth = 0;
  int tabIndex = 0;
  late final TabBar tabs;
  late final TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    tabs = TabBar(
      tabs: const [
        Tab(text: "周",),
        Tab(text: "月",)
      ],

      controller: tabController,
      onTap: (index) {
        if (tabIndex != index) {
          setState(() {
            tabIndex = index;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    dailyAttendanceState = context.read<DailyAttendanceState>();
    late Widget body;
    if (tabIndex == 0) {
      body = buildStatisticsWeekly(context, offsetWeek);
    } else {
      body = buildStatisticsMonthly(context, offsetMonth);
    }

    return Scaffold(
      appBar: AppBar(
        title: tabs,
      ),
      
      body: Center(
        child: Card(
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: body,
          ),
        ),
      ),
    );
  }

  Widget buildStatisticsWeekly(BuildContext context, int offset) {
    return FutureBuilder(
        future: dailyAttendanceState.statisticsWeekly(offset),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Center(child: Text(snapshot.error.toString()),);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

          
          final keys = snapshot.requireData.keys.toList();
          final listView = ListView.builder(
              itemCount: snapshot.requireData.length,
              itemBuilder: (context, index) {
                final da.Task task = keys[index];
                final List<da.Progress> progresses = snapshot.requireData[task]!;
                
                return buildStatisticsWeeklyListViewItem(context, task, progresses);
              }
          );

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              buildChangeWeek(context, snapshot.requireData.isEmpty),
              buildStatisticsWeeklyHead(context),
              Expanded(child: listView),
            ],
          );
        }
    );
  }

  Widget buildStatisticsWeeklyHead(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(),
          ),

          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: StatisticsPage.weekDays.map<Widget>((e) {
                bool flag = isCurrentDay(e);
                Color color = flag ? Colors.white : Colors.black;
                TextStyle textStyle = TextStyle(color: color, fontSize: dailyAttendanceSettings["page.statistics.week.head.font.size"]);
                return Container(
                  width: dailyAttendanceSettings["page.statistics.week.item.size"],
                  height: dailyAttendanceSettings["page.statistics.week.item.size"],
                  margin: dailyAttendanceSettings["page.statistics.week.item.margin"],

                  decoration: BoxDecoration(
                      color: flag ? Colors.blue : Colors.transparent,
                      shape: BoxShape.circle
                  ),

                  child: Center(child: Text(e, style: textStyle,),),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );

  }
  
  Widget buildStatisticsWeeklyListViewItem(BuildContext context, da.Task task, List<da.Progress> progresses) {
    final Widget left = Expanded(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          buildIcon(context, task.icon),
          const SizedBox(width: 4,),
          Text(task.name)
        ],
      ),
    );

    final Color color = iconColor(task.icon);

    final Widget right = Expanded(
      flex: 2,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: StatisticsPage.weekDays.indexed.map<Widget>((e) {
          final da.Progress progress = progresses[e.$1];
          final Color itemColor = progressColor(progress, color);
          return Container(
            width: dailyAttendanceSettings["page.statistics.week.item.size"],
            height: dailyAttendanceSettings["page.statistics.week.item.size"],
            margin: dailyAttendanceSettings["page.statistics.week.item.margin"],

            decoration: BoxDecoration(
              color: itemColor
            ),
          );
        }).toList(),
      ),
    );

    return ListTile(
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          left,
          right
        ],
      ),
    );
  } 
  
  Widget buildChangeWeek(BuildContext context, bool matchLowerBound) {
    final now = DateTime.now();
    final distance = StatisticsPage.weekDayDistance[now.weekday]!;
    final startOfWeek = now.subtract(Duration(days: distance)).subtract(Duration(days: 7 * offsetWeek.abs()));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    late String text;
    if (offsetWeek == 0) {
      text = "本周";
    } else if (offsetWeek == -1) {
      text = "上周";
    } else {
      text = "${startOfWeek.year}.${startOfWeek.month}.${startOfWeek.day}-${endOfWeek.year}.${endOfWeek.month}.${endOfWeek.day}";
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: matchLowerBound ? null : () {
            setState(() {
              offsetWeek -= 1;
            });
          },

          icon: Icon(Icons.arrow_back_ios_rounded, color: matchLowerBound ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
        ),

        Expanded(child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold),),),),

        IconButton(
          onPressed: offsetWeek == 0 ? null : () {
            setState(() {
              offsetWeek += 1;
            });
          },

          icon: Icon(Icons.arrow_forward_ios_rounded, color: offsetWeek == 0 ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
        )
      ],
    );
  }

  Widget buildStatisticsMonthly(BuildContext context, int offset) {
    return FutureBuilder(
      future: dailyAttendanceState.statisticsMonthly(offset),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.stackTrace);
          return Center(child: Text(snapshot.error.toString()),);
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(),);
        }

        final GridView gridView = GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1,
          children: snapshot.requireData.entries.map<Widget>((entry) => buildCalendar(context, entry.key, entry.value)).toList(),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildChangeMonth(context, snapshot.requireData.isEmpty),
                gridView
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildChangeMonth(BuildContext context, bool matchLowerBound) {
    final now = DateTime.now();
    late String text;
    if (offsetMonth == 0) {
      text = "${now.month}月";
    } else {
      final time = DateTime(now.year, now.month - offsetMonth.abs(), 1);
      text = "${time.year}年${time.month}月";
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          onPressed: matchLowerBound ? null : () {
            setState(() {
              offsetMonth -= 1;
            });
          },

          icon: Icon(Icons.arrow_back_ios_rounded, color: matchLowerBound ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
        ),

        Expanded(child: Center(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),),),

        IconButton(
          onPressed: offsetMonth == 0 ? null : () {
            setState(() {
              offsetMonth += 1;
            });
          },

          icon: Icon(Icons.arrow_forward_ios_rounded, color: offsetMonth == 0 ? const Color.fromRGBO(0, 0, 0, 0.3) : Colors.blue,),
        )
      ],
    );
  }

  Widget buildCalendar(BuildContext context, da.Task task, List<da.Progress> progresses) {
    final Widget icon = buildIcon(context, task.icon);
    final Color color = iconColor(task.icon);

    final children = progresses.map<Widget>((e) => Container(
      width: dailyAttendanceSettings["page.statistics.calendar.item.size"],
      height: dailyAttendanceSettings["page.statistics.calendar.item.size"],
      margin: dailyAttendanceSettings["page.statistics.calendar.item.margin"],
      padding: dailyAttendanceSettings["page.statistics.calendar.item.padding"],
      decoration: BoxDecoration(
        color: progressColor(e, color)
      ),
    )).toList();

    final blank = Container(
      width: dailyAttendanceSettings["page.statistics.calendar.item.size"],
      height: dailyAttendanceSettings["page.statistics.calendar.item.size"],
      margin: dailyAttendanceSettings["page.statistics.calendar.item.margin"],
    );

    children.insert(0, blank);
    children.insert(0, blank);

    return Card(
      color: Colors.white,
      child: ListTile(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 4,),
            Text(task.name)
          ],
        ),

        subtitle: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          children: children,
        ),
      ),
    );
  }

  Color progressColor(da.Progress progress, Color color) {
    switch (progress.runtimeType) {
      case da.Done:
        return color;
      case da.Doing:
        return color.withOpacity((progress as da.Doing).amount.toDouble() / progress.total);
      case da.NotScheduled:
        return const Color.fromRGBO(0, 0, 0, 0.2);
      default:
        return const Color.fromRGBO(0, 0, 0, 0.05);
    }
  }

  Widget buildIcon(BuildContext context, da.Icon taskIcon) {
    late Color color;
    late Widget icon;
    if (taskIcon is da.Word) {
      color = flatUIColors[taskIcon.color]!;
      icon = Container(
        width: dailyAttendanceSettings["widget.taskcard.icon.size"],
        height: dailyAttendanceSettings["widget.taskcard.icon.size"],
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle
        ),

        child: Center(child: Text(taskIcon.char, style: const TextStyle(color: Colors.white),)),
      );
    } else {
      taskIcon as da.Image;
      color = flatUIColors[taskIcon.backGroundColor]!;
      icon = Container(
        width: dailyAttendanceSettings["widget.taskcard.icon.size"],
        height: dailyAttendanceSettings["widget.taskcard.icon.size"],
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle
        ),

        child: Center(child: Image.network(dailyAttendanceState.imageUrl(taskIcon.entryId)),),
      );
    }

    return icon;
  }

  Color iconColor(da.Icon icon) {
    if (icon is da.Word) {
      return flatUIColors[icon.color]!;
    } else {
      return flatUIColors[(icon as da.Image).backGroundColor]!;
    }
  }

  bool isCurrentDay(String weekDay) {
    final now = DateTime.now();
    final index = now.weekday - 1;
    return StatisticsPage.weekDays[index] == weekDay;
  }
}