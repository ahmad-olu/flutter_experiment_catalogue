import 'package:pocketbase/pocketbase.dart';

class Todo extends RecordModel {
  Todo({
    required String id,
    required this.todo,
    required this.done,
    Map<String, dynamic>? data,
  }) : super(data) {
    this.id = id;
    this.data['todo'] = todo;
    this.data['done'] = done;
  }

  factory Todo.fromRecordModel(RecordModel record) {
    return Todo(
      id: record.id,
      todo: record.get<String>('todo', ''),
      done: record.get<bool>('done', false),
      data: record.data,
    );
  }

  final String todo;
  final bool done;
}
