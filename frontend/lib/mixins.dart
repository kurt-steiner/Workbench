import 'package:frontend/state/daily-attendance.dart';
import 'package:frontend/state/todolist.dart';

mixin StateMixin {
  TodoListState? _todoListState;
  TodoListState get todoListState => _todoListState!;
  set todoListState(TodoListState value) => _todoListState ??= value;

  DailyAttendanceState? _dailyAttendanceState;
  DailyAttendanceState get dailyAttendanceState => _dailyAttendanceState!;
  set dailyAttendanceState(DailyAttendanceState value) => _dailyAttendanceState ??= value;
}