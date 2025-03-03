import 'package:bloc/bloc.dart';
import 'package:experiment_catalogue/app/pocket_base_db.dart';
import 'package:experiment_catalogue/applications/01_todo/model/todo.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(TodoState.initial());

  void inputTodoForm(String todo) => emit(state.copyWith(todoInput: todo));
  void addToUpdate(String id) {
    if (id == state.updateId) {
      emit(
          state.copyWith(todoInput: '', isUpdate: false, updateId: () => null),);
    } else {
      final todo = state.todos.firstWhere((e) => e.id == id);
      emit(state.copyWith(
          todoInput: todo.todo, isUpdate: true, updateId: () => todo.id,),);
    }
  }

  void previousPage() =>
      emit(state.copyWith(page: state.page > 1 ? state.page - 1 : state.page));

  void nextPage() => emit(
        state.copyWith(
          page: state.page < state.totalPage! ? state.page + 1 : state.page,
        ),
      );

  Future<void> getTodos() async {
    try {
      emit(state.copyWith(todoStatus: TodoStatus.loading));
      final res = await pbDb.collection('01_todo').getList(
            page: state.page,
            perPage: 11,
          );
      final todos = res.items.map(Todo.fromRecordModel).toList();

      emit(
        state.copyWith(
          todoStatus: TodoStatus.loaded,
          todos: todos,
          totalPage: res.totalPages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          todoStatus: TodoStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
    // final a = pbDb.collection('01_todo').subscribe('*', (e) {
    //   print(e.action);
    //   print(e.record);
    // flutter: create
    // flutter: {"collectionId":"pbc_2859720808","collectionName":"01_todo","created":"2025-01-22 22:03:49.122Z","done":false,"id":"69418466cd3f2z9","todo":"todo 4","updated":"2025-01-22 22:03:49.122Z"}
    //});
  }

  Future<void> createTodos() async {
    try {
      emit(state.copyWith(todoFormStatus: TodoFormStatus.loading));

      if (state.isUpdate == true) {
        final res = await pbDb
            .collection('01_todo')
            .update(state.updateId!, body: {'todo': state.todoInput});
        final todo = Todo.fromRecordModel(res);

        emit(
          state.copyWith(
            todos: state.todos.map((e) {
              if (e.id == todo.id) {
                return todo;
              }
              return e;
            }).toList(),
          ),
        );
      } else {
        final body = <String, dynamic>{'todo': state.todoInput, 'done': false};

        final _res0 = await pbDb.collection('01_todo').create(body: body);
      }

      emit(
          state.copyWith(todoFormStatus: TodoFormStatus.loaded, todoInput: ''),);
    } catch (e) {
      emit(
        state.copyWith(
          todoFormStatus: TodoFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateTodoIsDone(String id) async {
    try {
      final req = state.todos.firstWhere((e) => e.id == id);
      final res = await pbDb
          .collection('01_todo')
          .update(id, body: {'done': !req.done});
      final todo = Todo.fromRecordModel(res);

      emit(
        state.copyWith(
          todos: state.todos.map((e) {
            if (e.id == id) {
              return todo;
            }
            return e;
          }).toList(),
        ),
      );
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
