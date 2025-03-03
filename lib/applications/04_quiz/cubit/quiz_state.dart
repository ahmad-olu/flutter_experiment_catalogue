part of 'quiz_cubit.dart';

@immutable
class QuizState {

  factory QuizState.fromMap(Map<String, dynamic> map) {
    return QuizState(
      currentQuestionIndex: map['currentQuestionIndex'] as int,
      isQuizComplete: map['isQuizComplete'] as bool,
      questions: List<Quiz>.from(
        (map['questions'] as List<int>).map<Quiz>(
          (x) => Quiz.fromMap(x as Map<String, dynamic>),
        ),
      ),
      selectedAnswers: List<int?>.from((map['selectedAnswers'] as List<int?>)),
    );
  }
  const QuizState({
    required this.currentQuestionIndex,
    required this.isQuizComplete,
    required this.questions,
    required this.selectedAnswers,
  });

  factory QuizState.initial() => const QuizState(
        currentQuestionIndex: 0,
        isQuizComplete: false,
        questions: [],
        selectedAnswers: [],
      );

  final int currentQuestionIndex;
  final bool isQuizComplete;
  final List<Quiz> questions;
  final List<int?> selectedAnswers;

  // Quiz get currentQuestion => questions[currentQuestionIndex];

  int calculateScore() {
    var score = 0;
    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedAnswerIndex = selectedAnswers[i];
      if (selectedAnswerIndex != null &&
          question.answers[selectedAnswerIndex].value) {
        score++;
      }
    }
    return score;
  }

  QuizState copyWith({
    int? currentQuestionIndex,
    bool? isQuizComplete,
    List<Quiz>? questions,
    List<int?>? selectedAnswers,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isQuizComplete: isQuizComplete ?? this.isQuizComplete,
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }

  @override
  bool operator ==(covariant QuizState other) {
    if (identical(this, other)) return true;

    return other.currentQuestionIndex == currentQuestionIndex &&
        other.isQuizComplete == isQuizComplete &&
        listEquals(other.questions, questions) &&
        listEquals(other.selectedAnswers, selectedAnswers);
  }

  @override
  int get hashCode {
    return currentQuestionIndex.hashCode ^
        isQuizComplete.hashCode ^
        questions.hashCode ^
        selectedAnswers.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentQuestionIndex': currentQuestionIndex,
      'isQuizComplete': isQuizComplete,
      'questions': questions.map((x) => x.toMap()).toList(),
      'selectedAnswers': selectedAnswers,
    };
  }
}
