import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/mixins.dart';
import 'package:frontend/model/daily-attendance.dart' as da;
import 'package:frontend/model/enumeration.dart';
import 'package:frontend/page/daily_attendance/color-select.dart';
import 'package:frontend/request/daily-attendance.dart';
import 'package:frontend/settings.dart';
import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/widget/daily_attendance/edit-frequency.dart';
import 'package:provider/provider.dart';
import 'package:frontend/model/daily-attendance.dart' as da;

class TaskEdit extends StatefulWidget {
  static final List<String> units = [
    "次", "杯", "毫升", "分钟", "小时", "公里"
  ];

  static final RegExp postiveRegex = RegExp(r"^[1-9]\d*$");

  @override
  _TaskEditState createState() => _TaskEditState();
}

class _TaskEditState extends State<TaskEdit> with StateMixin {
  late UpdateTaskRequest request;
  late final TextEditingController nameController;
  late final TextEditingController encouragementController;
  late final TextEditingController wordController;

  late final ValueNotifier<bool> enableNotifier;
  late final ValueNotifier<da.IconMode> modeNotifier;
  late final ValueNotifier<da.ImageCompose> imageNotifier;
  String word = "";

  int entryId = -1;
  int backGroundId = - 1;
  FlatUIColor backGroundColor = ColorSelect.defaultColor;
  da.Task get currentTask => dailyAttendanceState.currentTask!;
  late da.Task copyOfTask;

  bool get enable {
    bool flag1 = nameController.text.isNotEmpty &&
        encouragementController.text.isNotEmpty;
    bool flag2 = imageNotifier.value.entry != null &&
        imageNotifier.value.background != null;
    bool flag3 = wordController.text.isNotEmpty;

    return flag1 && (flag2 || flag3);
  }

  @override
  void initState() {
    super.initState();
    dailyAttendanceState = context.read<DailyAttendanceState>();

    copyOfTask = currentTask.copy();
    request = UpdateTaskRequest.fromObject(copyOfTask);
    nameController = TextEditingController(text: copyOfTask.name);
    encouragementController = TextEditingController(text: copyOfTask.encouragement);

    String wordText = "";
    if (copyOfTask.icon is da.Word) {
      wordText = (copyOfTask.icon as da.Word).char;
    }

    Widget? entry;
    Widget? backGround;

    if (copyOfTask.icon is da.Image) {
      da.Image taskIcon = copyOfTask.icon as da.Image;
      entry = Image.network(
        dailyAttendanceState.imageUrl(taskIcon.entryId),
        width: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
        height: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
      );

      backGround = Image.network(
        dailyAttendanceState.imageUrl(taskIcon.backGroundId),
        width: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
        height: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
      );
    }

    imageNotifier = ValueNotifier(da.ImageCompose(entry: entry, background: backGround));
    wordController = TextEditingController(text: wordText);
    enableNotifier = ValueNotifier(enable);
    modeNotifier = ValueNotifier(copyOfTask.icon is da.Image ? da.IconMode.image : da.IconMode.word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              request = UpdateTaskRequest.fromObject(copyOfTask);
              await dailyAttendanceState.updateTask(request);

              dailyAttendanceNavigationKey.currentState!.pop();
            },

            icon: const Icon(Icons.check),
          )
        ],
      ),

      body: ListView(
        children: [
          Card(child: buildInputName(context),),
          Card(child: buildUploadIcon(context),),
          Card(child: buildEditGoal(context),),
          Card(child: buildEditStartTime(context),),
          TaskEditFrequency(updateRequest: request,),
          Card(child: buildEditKeepDays(context),),
          Card(child: buildEditGroup(context),),
          Card(child: buildNotifyTimes(context),),
          Card(child: buildInputEncouragement(context),)
        ],
      ),
    );
  }

  Widget buildInputName(BuildContext context) {
    return ListTile(
      title: const Text("习惯名称"),
      subtitle: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          hintText: "请输入习惯名称",
        ),

        onChanged: (String? value) {
          if (value != null) {
            copyOfTask.name = value;
          }
        },
      ),
    );
  }

  Widget buildUploadIcon(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: modeNotifier,
        builder: (_, value, child) {
          return ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    modeNotifier.value = da.IconMode.image;
                  },

                  icon: Icon(Icons.image_outlined, color: value == da.IconMode.image ? Colors.blue : null,),
                ),

                IconButton(
                  onPressed: () {
                    modeNotifier.value = da.IconMode.word;
                  },

                  icon: Icon(Icons.font_download_outlined, color: value == da.IconMode.word ? Colors.blue : null,),
                )
              ],
            ),

            subtitle: value == da.IconMode.image ? buildUploadIconImage(context) : buildUploadIconWord(context),
          );
        }
    );
  }

  Widget buildUploadIconImage(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["png"]);
            if (result != null) {
              final path = result.files.single.path!;
              imageNotifier.value = imageNotifier.value.copyWith(entry: Image.file(
                File(path),
                width: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
                height: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
              ));

              final file = await MultipartFile.fromFile(path);
              final image = await dailyAttendanceState.imageApi.insertOne(file);

              entryId = image.id;
            }
          },

          child: Container(
              width: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
              height: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1)
              ),
              child: ValueListenableBuilder(
                valueListenable: imageNotifier,
                builder: (_, value, child) {
                  if (value.entry != null) {
                    return value.entry!;
                  } else {
                    return const Center(
                      child: Text("添加图标"),
                    );
                  }
                },
              )
          ),
        ),

        InkWell(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["png"]);
            if (result != null) {
              final path = result.files.single.path!;
              imageNotifier.value = imageNotifier.value.copyWith(background: Image.file(
                File(path),
                width: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
                height: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
              ));

              final file = await MultipartFile.fromFile(path);
              final image = await dailyAttendanceState.imageApi.insertOne(file);

              backGroundId = image.id;
            }
          },

          child: Container(
              width: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
              height: dailyAttendanceSettings["page.taskadd.upload-icon.image.size"],
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1)
              ),
              child: ValueListenableBuilder(
                valueListenable: imageNotifier,
                builder: (_, value, child) {
                  if (value.background != null) {
                    return value.background!;
                  } else {
                    return const Center(
                      child: Text("添加背景图片"),
                    );
                  }
                },
              )
          ),
        )
      ],
    );
  }

  Widget buildUploadIconWord(BuildContext context) {
    return TextField(
      controller: wordController,
      decoration: const InputDecoration(
        hintText: "请输入文字",
      ),

      maxLength: 1,
    );
  }

  Widget buildSelectColor(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => ListTile(
        title: const Text("颜色"),
        subtitle: InkWell(
          onTap: () async {
            FlatUIColor? color = await dailyAttendanceNavigationKey.currentState!.pushNamed<dynamic>("daily-attendance/color-select");
            if (color != null) {
              setState(() {
                backGroundColor = color;
              });
            }
          },

          child: Container(
            width: dailyAttendanceSettings["page.taskadd.color-select.size"],
            height: dailyAttendanceSettings["page.taskadd.color-select.size"],
            color: flatUIColors[backGroundColor]!,
          ),
        ),
      ),
    );
  }

  Widget buildInputEncouragement(BuildContext context) {
    return ListTile(
      title: const Text("鼓励语"),
      subtitle: TextField(
        controller: encouragementController,
        decoration: const InputDecoration(
          hintText: "请输入鼓励语",
        ),

        onChanged: (String? value) {
          if (value != null) {
            copyOfTask.encouragement = value;
          }
        },
      ),
    );
  }

  // step 2
  Widget buildEditGoal(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        late String text;

        if (copyOfTask.goal is da.CurrentDay) {
          text = "当天完成一次";
        } else {
          da.Amount amount = copyOfTask.goal as da.Amount;
          text = "${amount.total}${amount.unit}/天";
        }

        return ListTile(
          leading: const Text("目标"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text),
              const SizedBox(width: 4,),
              const Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),

          onTap: () async {
            da.Goal? goal = await showDialogEditGoal(context);
            if (goal != null) {
              setState(() {
                copyOfTask.goal = goal;
              });
            }
          },
        );
      },
    );
  }

  Future<da.Goal?> showDialogEditGoal(BuildContext context) async {
    da.Goal goal = copyOfTask.goal;

    List<Widget> actions() => [
      TextButton(
        onPressed: () {
          dailyAttendanceNavigationKey.currentState!.pop();
        },

        child: const Text("取消"),
      ),

      TextButton(
        onPressed: () {
          dailyAttendanceNavigationKey.currentState!.pop(goal);
        },

        child: const Text("确定"),
      )
    ];

    return await showDialog(context: context, useRootNavigator: false, builder: (context) => AlertDialog(
      title: const Text("目标"),
      content: buildEditGoalContent(context, (value) {
        goal = value;
      }),
      actions: actions(),
    ));
  }

  Widget buildEditGoalContent(BuildContext context, void Function(da.Goal) onChanged) {
    final goal = copyOfTask.goal;
    da.Goal resultGoal = da.CurrentDay();
    final ValueNotifier<int> goalType = ValueNotifier(goal is da.CurrentDay ? 1 : 2);
    late String textTotal;
    late String textEachAmount;
    String unit = TaskEdit.units.first;

    if (goal is da.Amount) {
      textTotal = goal.total.toString();
      textEachAmount = goal.eachAmount.toString();
      unit = goal.unit;
    } else {
      textTotal = "1";
      textEachAmount = "1";
      unit = "次";
    }

    final Widget radios = ValueListenableBuilder(
        valueListenable: goalType,
        builder: (_, value, child)  {
          return Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile(title: const Text("当天完成打卡"), value: 1, groupValue: value, onChanged: (value) {
                  if (value != null) {
                    goalType.value = value;
                    resultGoal = da.CurrentDay();
                    onChanged(resultGoal);
                  }
                }),

                RadioListTile(title: const Text("当天完成一定量"), value: 2, groupValue: value, onChanged: (value) {
                  if (value != null) {
                    goalType.value = value;
                    resultGoal = da.Amount(total: int.parse(textTotal), unit: unit, eachAmount: int.parse(textEachAmount));
                    onChanged(resultGoal);
                  }
                },),

              ],
            ),
          );
        });

    final totalController = TextEditingController(text: textTotal);
    final eachAmountController = TextEditingController(text: textEachAmount);

    final Widget editPart = StatefulBuilder(builder: (context, setState) {
      final Widget eachDay = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("每天"),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: dailyAttendanceSettings["page.taskadd.edit-gaol.textfield.width"],
                  child: TextField(
                    decoration: null,
                    controller: totalController,
                    keyboardType: TextInputType.number,

                    onChanged: (value) {
                      if (value.isNotEmpty && TaskEdit.postiveRegex.hasMatch(value)) {
                        setState(() {
                          textTotal = value;
                          resultGoal = da.Amount(total: int.parse(textTotal), unit: unit, eachAmount: int.parse(textEachAmount));
                          onChanged(resultGoal);
                        });
                      }
                    },
                  ),
                ),

                MenuAnchor(
                  menuChildren: TaskEdit.units
                      .map<Widget>(
                          (e) => MenuItemButton(
                        child: Text(e),
                        onPressed: () {
                          setState(() {
                            unit = e;
                          });
                        },
                      ))
                      .toList(),

                  builder: (context, controller, child) {
                    return TextButton(
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },

                      child: Text(unit),
                    );
                  },
                )
              ],
            ),
          )
        ],
      );

      final Widget eachAmount = Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("每次记录 ($unit)"),
          SizedBox(
            width: dailyAttendanceSettings["page.taskadd.edit-gaol.textfield.width"],
            child: TextField(
              decoration: null,
              controller: eachAmountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty && TaskEdit.postiveRegex.hasMatch(value)) {
                  setState(() {
                    textEachAmount = value;
                    resultGoal = da.Amount(total: int.parse(textTotal), unit: unit, eachAmount: int.parse(textEachAmount));
                    onChanged(resultGoal);
                  });
                }
              },
            ),
          )
        ],
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          eachDay,
          eachAmount
        ],
      );
    });

    return ValueListenableBuilder(
        valueListenable: goalType,
        builder: (_, value, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            radios,
            const Divider(),
            Offstage(
              offstage: value != 2,
              child: editPart,
            )
          ],
        )
    );
  }

  Widget buildEditStartTime(BuildContext context) {
    DateTime startTime = copyOfTask.startTime;
    String text = "${startTime.month}月${startTime.day}日";

    return StatefulBuilder(
      builder: (context, setState) => ListTile(
        leading: const Text("开始日期"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(width: 4,),
            const Icon(Icons.arrow_forward_ios_rounded)
          ],
        ),

        onTap: () async {
          DateTime firstDate = DateTime(startTime.year, startTime.month, 1);

          DateTime? dateTime = await showDatePicker(
              context: context,
              initialDate: startTime,
              firstDate: firstDate,
              lastDate: DateTime(startTime.year + 1)
          );

          if (dateTime != null) {
            setState(() {
              copyOfTask.startTime = dateTime;
            });
          }
        },
      ),
    );
  }

  Widget buildEditKeepDays(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => ListTile(
        leading: const Text("坚持天数"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(copyOfTask.keepdays.toString()),
            const SizedBox(width: 4,),
            const Icon(Icons.arrow_forward_ios_rounded)
          ],
        ),

        onTap: () async {
          da.KeepDays? keepdays = await showDialogEditKeepDays(context);
          if (keepdays != null) {
            setState(() {
              copyOfTask.keepdays = keepdays;
            });
          }
        },
      ),
    );
  }

  Future<da.KeepDays?> showDialogEditKeepDays(BuildContext context) async {
    da.KeepDays keepdays = copyOfTask.keepdays.copy();

    List<Widget> actions = [
      TextButton(
          onPressed: () {
            dailyAttendanceNavigationKey.currentState!.pop();
          },

          child: const Text("取消")
      ),

      TextButton(
        onPressed: () {
          dailyAttendanceNavigationKey.currentState!.pop(keepdays);
        },

        child: const Text("确定"),
      )
    ];

    return await showDialog(context: context, useRootNavigator: false, builder: (context) => AlertDialog(
        actions: actions,
        title: const Text("坚持天数"),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                  title: const Text("永远"),
                  value: da.Forever(),
                  groupValue: keepdays,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        keepdays = value;
                      });

                    }
                  }
              ),

              RadioListTile(
                title: const Text("7天"),
                value: da.Manual(days: 7),
                groupValue: keepdays,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      keepdays = value;
                    });

                  }
                },
              ),

              RadioListTile(
                title: const Text("21天"),
                value: da.Manual(days: 21),
                groupValue: keepdays,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      keepdays = value;
                    });

                  }
                },
              ),

              RadioListTile(
                title: const Text("30天"),
                value: da.Manual(days: 30),
                groupValue: keepdays,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      keepdays = value;
                    });

                  }
                },
              ),

              RadioListTile(
                title: const Text("100天"),
                value: da.Manual(days: 100),
                groupValue: keepdays,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      keepdays = value;
                    });

                  }
                },
              ),

              RadioListTile(
                title: const Text("365天"),
                value: da.Manual(days: 365),
                groupValue: keepdays,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      keepdays = value;
                    });

                  }
                },
              ),
            ],
          ),
        )
    ));
  }

  Widget buildEditGroup(BuildContext context) {
    List<String> names = ["上午", "下午", "晚上", "其他"];

    return StatefulBuilder(
      builder: (context, setState) {
        List<bool> flags = List.generate(4, (index) => false);
        switch (copyOfTask.group) {
          case da.Group.noon:
            flags[0] = true;
            break;
          case da.Group.afternoon:
            flags[1] = true;
            break;

          case da.Group.night:
            flags[2] = true;
            break;
          case da.Group.other:
            flags[3] = true;
            break;
        }

        return ListTile(
            title: const Text("所属分组"),
            subtitle: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: names.indexed.map<Widget>((e) => buildEditGroupItem(context, index: e.$1, name: e.$2, flags: flags, setState: setState)).toList()
            )
        );
      },
    );
  }

  Widget buildEditGroupItem(BuildContext context, {
    required int index,
    required String name,
    required List<bool> flags,
    required void Function(void Function()) setState
  }) {
    return ChoiceChip(
        label: Text(name),
        selected: flags[index],
        onSelected: (value) {
          setState(() {
            switch (index) {
              case 0:
                copyOfTask.group = da.Group.noon;
                break;
              case 1:
                copyOfTask.group = da.Group.afternoon;
                break;
              case 2:
                copyOfTask.group = da.Group.night;
                break;
              case 3:
                copyOfTask.group = da.Group.other;
                break;
            }
          });
        }
    );
  }

  Widget buildNotifyTimes(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        final Widget addButton = TextButton(
          onPressed: () async {
            TimeOfDay initialTime = TimeOfDay.now();
            TimeOfDay? timeOfDay = await showTimePicker(context: context, initialTime: initialTime);

            if (timeOfDay != null) {
              setState(() {
                copyOfTask.notifyTimes.add(da.NotifyTime(hour: timeOfDay.hour, minute: timeOfDay.minute));
              });
            }
          },

          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              Text("添加")
            ],
          ),
        );

        final List<Widget> children = [
          ...copyOfTask.notifyTimes.map<Widget>((e) => buildNotifyTimeItem(context, time: e, setState: setState)).toList(),
          addButton
        ];

        return ListTile(
          title: const Text("提醒"),
          subtitle: copyOfTask.notifyTimes.isEmpty ? addButton : Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children
          ),
        );
      },
    );
  }

  Widget buildNotifyTimeItem(BuildContext context, {required da.NotifyTime time, required void Function(void Function()) setState}) {
    return InputChip(
      label: Text(time.toString()),
      onPressed: () async {
        TimeOfDay initialTime = TimeOfDay(hour: time.hour, minute: time.minute);
        TimeOfDay? timeOfDay = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );

        if (timeOfDay != null) {
          setState(() {
            int index = copyOfTask.notifyTimes.indexWhere((element) => element == time);
            copyOfTask.notifyTimes[index] = da.NotifyTime(hour: timeOfDay.hour, minute: timeOfDay.minute);
          });
        }
      },

      onDeleted: () {
        setState(() {
          copyOfTask.notifyTimes.removeWhere((element) => element == time);
        });
      },
    );
  }

}