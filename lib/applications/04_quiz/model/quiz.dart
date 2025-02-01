import 'package:flutter/foundation.dart';

class Quiz {
  Quiz({
    required this.id,
    required this.question,
    required this.answers,
    required this.explanation,
    required this.tip,
    required this.tags,
    required this.difficulty,
  });

  final int id;
  final String question;
  final List<MapEntry<String, bool>> answers;
  final String? explanation;
  final String? tip;
  final List<Map<String, dynamic>> tags;
  final String difficulty;

  Quiz copyWith({
    int? id,
    String? question,
    List<MapEntry<String, bool>>? answers,
    String? explanation,
    String? tip,
    List<Map<String, dynamic>>? tags,
    String? difficulty,
  }) {
    return Quiz(
      id: id ?? this.id,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      explanation: explanation ?? this.explanation,
      tip: tip ?? this.tip,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    final answers = <MapEntry<String, bool>>[];
    map['answers'].forEach((key, value) {
      if (value != null) {
        answers.add(
          MapEntry(
            value as String,
            map['correct_answers']['${key}_correct'] == 'true',
          ),
        );
      }
    });
    return Quiz(
      id: map['id'] as int,
      question: map['question'] as String,
      answers: answers,
      explanation:
          map['explanation'] != null ? map['explanation'] as String : null,
      tip: map['tip'] != null ? map['tip'] as String : null,
      tags: List<Map<String, dynamic>>.from(map['tags'] as List),
      difficulty: map['difficulty'] as String? ?? 'Unknown',
    );
  }

  @override
  String toString() {
    return 'Quiz(id: $id, question: $question, answers: $answers, explanation: $explanation, tip: $tip, tags: $tags, difficulty: $difficulty)';
  }

  @override
  bool operator ==(covariant Quiz other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.question == question &&
        listEquals(other.answers, answers) &&
        other.explanation == explanation &&
        other.tip == tip &&
        listEquals(other.tags, tags) &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        answers.hashCode ^
        explanation.hashCode ^
        tip.hashCode ^
        tags.hashCode ^
        difficulty.hashCode;
  }

  Map<String, dynamic> toMap() {
    final answersMap = <String, String?>{};
    final correctAnswersMap = <String, String>{};

    for (var i = 0; i < answers.length; i++) {
      final answerKey =
          'answer_${String.fromCharCode(97 + i)}'; // Converts 0 -> 'a', 1 -> 'b', etc.
      answersMap[answerKey] =
          answers[i].key; // Map the answer string to the key
      correctAnswersMap['${answerKey}_correct'] =
          answers[i].value ? 'true' : 'false';
    }

    return {
      'id': id,
      'question': question,
      'description': explanation,
      'answers': answersMap,
      'multiple_correct_answers':
          answers.any((answer) => answer.value) ? 'true' : 'false',
      'correct_answers': correctAnswersMap,
      'correct_answer': correctAnswersMap.entries
          .firstWhere((entry) => entry.value == 'true')
          .key,
      'explanation': explanation,
      'tip': tip,
      'tags': tags.map((tag) => {'name': tag['name']}).toList(),
      'category': '',
      'difficulty': difficulty,
    };
  }
}
