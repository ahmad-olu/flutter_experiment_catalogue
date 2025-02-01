import 'dart:convert' as j;
import 'dart:io' as io;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:experiment_catalogue/app/env.dart';
import 'package:experiment_catalogue/applications/04_quiz/model/quiz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'quiz_state.dart';

const limit = 10;

class QuizCubit extends HydratedCubit<QuizState> {
  QuizCubit() : super(QuizState.initial());

  Future<void> initialize() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity.contains(ConnectivityResult.none)) {
      print('No internet connection. Using locally stored data.');
      return;
    }
    try {
      final uri = Uri.parse(
          'https://quizapi.io/api/v1/questions?apiKey=$quizApiApiKey&limit=$limit');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = j.json.decode(res.body) as List<dynamic>;
        final questions =
            data.map((e) => Quiz.fromMap(e as Map<String, dynamic>)).toList();
        emit(
          state.copyWith(
            questions: questions,
            selectedAnswers: List.filled(questions.length, null),
          ),
        );
      } else {
        throw Exception('Failed to load quiz questions: ${res.statusCode}');
      }
    } on http.ClientException catch (_) {
      return;
    } on io.SocketException catch (_) {
      return;
    } catch (e) {
      print('Error fetching quiz data: $e');
    }
  }

  void selectAnswer(int answerIndex) {
    final updatedAnswers = List<int?>.from(state.selectedAnswers);
    updatedAnswers[state.currentQuestionIndex] = answerIndex;

    emit(state.copyWith(selectedAnswers: updatedAnswers));
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1));
    } else {
      emit(state.copyWith(isQuizComplete: true));
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  void resetQuiz() {
    emit(QuizState(
      currentQuestionIndex: 0,
      isQuizComplete: false,
      questions: state.questions,
      selectedAnswers: List.filled(state.questions.length, null),
    ));
  }

  @override
  QuizState? fromJson(Map<String, dynamic> json) {
    try {
      // Deserialize the QuizState from JSON
      final questions = (json['questions'] as List<dynamic>).map((e) {
        final data = j.json.decode(e as String);
        return Quiz.fromMap(data as Map<String, dynamic>);
      }).toList();
      final selectedAnswers = (json['selectedAnswers'] as List<dynamic>)
          .map((e) => e as int?)
          .toList();
      return QuizState(
        currentQuestionIndex: json['currentQuestionIndex'] as int,
        isQuizComplete: json['isQuizComplete'] as bool,
        questions: questions,
        selectedAnswers: selectedAnswers,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(QuizState state) {
    return {
      'currentQuestionIndex': state.currentQuestionIndex,
      'isQuizComplete': state.isQuizComplete,
      'questions': state.questions
          .map((e) => j.json.encode(e.toMap()))
          .toList(), // Serialize each question

      'selectedAnswers': state.selectedAnswers,
    };
  }
}
