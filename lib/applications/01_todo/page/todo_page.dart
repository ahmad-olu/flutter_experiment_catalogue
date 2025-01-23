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
        title: const Text("01 TODO PAGE"),
        centerTitle: true,
      ),
      body: BlocConsumer<TodoCubit, TodoState>(
        listenWhen: (previous, current) => previous.page != current.page,
        listener: (context, state) => context.read<TodoCubit>().getTodos(),
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
                      trailing: Checkbox(
                        value: todo.done,
                        onChanged: (value) =>
                            context.read<TodoCubit>().updateTodoIsDone(todo.id),
                      ),
                      onTap: () =>
                          context.read<TodoCubit>().addToUpdate(todo.id),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const PaginationRow(),
                    Text(
                      "Is Update: ${state.isUpdate ? "✔️" : "❌"}   ➖  ID: ${state.updateId ?? '❌'}",
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: TodoInputField(),
                        ),
                        TodoNormalButton(
                          onPressed: () {
                            if (state.todoFormStatus ==
                                TodoFormStatus.loading) {
                              return;
                            }
                            context.read<TodoCubit>().createTodos();
                          },
                          child: state.todoFormStatus == TodoFormStatus.loading
                              ? const CircularProgressIndicator()
                              : const Text('Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TodoInputField extends StatefulWidget {
  const TodoInputField({super.key});

  @override
  _TodoInputFieldState createState() => _TodoInputFieldState();
}

class _TodoInputFieldState extends State<TodoInputField> {
  final todoController = TextEditingController();

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoCubit, TodoState>(
      listenWhen: (previous, current) =>
          previous.todoFormStatus == TodoFormStatus.loading &&
              current.todoFormStatus == TodoFormStatus.loaded ||
          previous.isUpdate == false && current.isUpdate == true,
      listener: (context, state) {
        todoController
          ..text = ''
          ..text = state.todoInput;
      },
      child: TextFormField(
        controller: todoController,
        decoration: const InputDecoration(),
        onChanged: (v) => context.read<TodoCubit>().inputTodoForm(v),
      ),
    );
  }
}

class PaginationRow extends StatelessWidget {
  const PaginationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TodoNormalButton(
              onPressed: () => context.read<TodoCubit>().previousPage(),
              child: const Text('Previous'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                state.page.toString(),
                style: const TextStyle(fontSize: 25),
              ),
            ),
            TodoNormalButton(
              onPressed: () => context.read<TodoCubit>().nextPage(),
              child: const Text('Next'),
            ),
          ],
        );
      },
    );
  }
}

class TodoNormalButton extends StatelessWidget {
  const TodoNormalButton({
    super.key,
    this.onPressed,
    required this.child,
  });
  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(side: const BorderSide()),
      child: child,
    );
  }
}
