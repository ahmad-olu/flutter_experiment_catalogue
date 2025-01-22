import 'package:bloc/bloc.dart';
import 'package:experiment_catalogue/app/pocket_base_db.dart';
import 'package:experiment_catalogue/applications/01_todo/model/todo.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(TodoState.initial());

  void inputTodoForm(String todo) => emit(state.copyWith(todoInput: todo));

  Future<void> getTodos() async {
    try {
      emit(state.copyWith(todoStatus: TodoStatus.loading));
      final res = await pbDb.collection('01_todo').getList(
            page: state.page,
            perPage: 6,
          );
      final todos = res.items.map(Todo.fromRecordModel).toList();
      emit(state.copyWith(todoStatus: TodoStatus.loaded, todos: todos));
    } catch (e) {
      emit(
        state.copyWith(
          todoStatus: TodoStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> createTodos() async {
    try {
      emit(state.copyWith(todoFormStatus: TodoFormStatus.loading));

      if (state.isUpdate == true) {
      } else {
        final body = <String, dynamic>{"todo": state.todoInput, "done": false};

        final _res = await pbDb.collection('01_todo').create(body: body);
      }

      emit(
          state.copyWith(todoFormStatus: TodoFormStatus.loaded, todoInput: ""));
    } catch (e) {
      emit(
        state.copyWith(
          todoFormStatus: TodoFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
