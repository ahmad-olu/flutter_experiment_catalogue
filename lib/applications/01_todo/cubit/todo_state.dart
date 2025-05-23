part of 'todo_cubit.dart';

enum TodoStatus {
  initial,
  loading,
  loaded,
  failure,
}

enum TodoFormStatus {
  loading,
  loaded,
  failure,
}

@immutable
class TodoState {
  const TodoState({
    required this.todos,
    required this.todoStatus,
    required this.todoFormStatus,
    this.page = 1,
    this.todoInput = '',
    this.isUpdate = false,
    this.totalPage,
    this.errorMessage,
    this.updateId,
  });

  factory TodoState.initial() => const TodoState(
        todos: [],
        todoStatus: TodoStatus.initial,
        todoFormStatus: TodoFormStatus.loaded,
      );

  final List<Todo> todos;
  final int page;
  final TodoStatus todoStatus;
  final TodoFormStatus todoFormStatus;
  final String? errorMessage;
  final String todoInput;
  final bool isUpdate;
  final int? totalPage;
  final String? updateId;

  @override
  String toString() {
    return 'TodoState(todos: $todos, page: $page, todoStatus: $todoStatus, todoFormStatus: $todoFormStatus, errorMessage: $errorMessage, todoInput: $todoInput, isUpdate: $isUpdate)';
  }

  TodoState copyWith({
    List<Todo>? todos,
    int? page,
    TodoStatus? todoStatus,
    TodoFormStatus? todoFormStatus,
    String? errorMessage,
    String? todoInput,
    bool? isUpdate,
    int? totalPage,
    String? Function()? updateId,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      page: page ?? this.page,
      todoStatus: todoStatus ?? this.todoStatus,
      todoFormStatus: todoFormStatus ?? this.todoFormStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      todoInput: todoInput ?? this.todoInput,
      isUpdate: isUpdate ?? this.isUpdate,
      totalPage: totalPage ?? this.totalPage,
      updateId: updateId != null ? updateId() : this.updateId,
    );
  }

  @override
  bool operator ==(covariant TodoState other) {
    if (identical(this, other)) return true;

    return listEquals(other.todos, todos) &&
        other.page == page &&
        other.todoStatus == todoStatus &&
        other.todoFormStatus == todoFormStatus &&
        other.errorMessage == errorMessage &&
        other.todoInput == todoInput &&
        other.isUpdate == isUpdate &&
        other.totalPage == totalPage &&
        other.updateId == updateId;
  }

  @override
  int get hashCode {
    return todos.hashCode ^
        page.hashCode ^
        todoStatus.hashCode ^
        todoFormStatus.hashCode ^
        errorMessage.hashCode ^
        todoInput.hashCode ^
        isUpdate.hashCode ^
        totalPage.hashCode ^
        updateId.hashCode;
  }
}
