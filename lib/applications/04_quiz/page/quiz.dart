import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/applications/04_quiz/cubit/quiz_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class Quiz04Page extends StatelessWidget {
  const Quiz04Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCubit()..initialize(),
      child: const Quiz04View(),
    );
  }
}

class Quiz04View extends StatelessWidget {
  const Quiz04View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state.isQuizComplete) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz Complete')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Congratulations! You completed the quiz.'),
                  Text('total = ${state.calculateScore()}/ 10'),
                  ElevatedButton(
                    onPressed: () => context.read<QuizCubit>().resetQuiz(),
                    child: const Text('Restart Quiz'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Quiz'),
            ),
            body: const Center(
              child: Text('No questions available.'),
            ),
          );
        }
        if (state.currentQuestionIndex < 0 ||
            state.currentQuestionIndex >= state.questions.length) {
          return const Scaffold(
            body: Center(child: Text('Invalid question index.')),
          );
        }
        final currentQuestion = state.questions[state.currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Question ${state.currentQuestionIndex + 1}/${state.questions.length}',
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  currentQuestion.question,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ...List.generate(currentQuestion.answers.length, (index) {
                  final answer = currentQuestion.answers[index];
                  final isSelected =
                      state.selectedAnswers[state.currentQuestionIndex] ==
                          index;
                  return ListTile(
                    title: Text(answer.key),
                    leading: Radio<int>(
                      value: index,
                      groupValue:
                          state.selectedAnswers[state.currentQuestionIndex],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<QuizCubit>().selectAnswer(value);
                        }
                      },
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  );
                }),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (state.currentQuestionIndex > 0)
                      ElevatedButton(
                        onPressed: context.read<QuizCubit>().previousQuestion,
                        child: const Text('Previous'),
                      ),
                    ElevatedButton(
                      onPressed: context.read<QuizCubit>().nextQuestion,
                      child: Text(
                        state.currentQuestionIndex < state.questions.length - 1
                            ? 'Next'
                            : 'Finish',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
