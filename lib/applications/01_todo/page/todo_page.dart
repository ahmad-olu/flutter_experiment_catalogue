import 'package:auto_route/annotations.dart';
import 'package:experiment_catalogue/applications/01_todo/cubit/todo_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class Todo01Page extends StatelessWidget {
  const Todo01Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoCubit()..getTodos(),
      child: const Todo01View(),
    );
  }
}

class Todo01View extends StatelessWidget {
  const Todo01View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("01 TODO PAGE"),
        centerTitle: true,
      ),
      body: BlocConsumer<TodoCubit, TodoState>(
        listener: (context, state) {
          // TODO?: implement listener
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: state.todos.length,
                itemBuilder: (context, index) {
                  final todo = state.todos[index];
                  return ListTile(
                    title: Text(todo.todo),
                  );
                },
              )),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Update: ${state.isUpdate.toString().toUpperCase()} && todoid"),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: state.todoInput,
                            decoration: InputDecoration(),
                            onChanged: (v) =>
                                context.read<TodoCubit>().inputTodoForm(v),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () =>
                                context.read<TodoCubit>().createTodos(),
                            child: Text('Send'))
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
