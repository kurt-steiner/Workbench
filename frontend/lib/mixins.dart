import 'package:frontend/state/todolist.dart';

mixin StateMixin {
  TodoListState? _todoListState;
  TodoListState get todoListState => _todoListState!;
  set todoListState(TodoListState value) => _todoListState ??= value;
}