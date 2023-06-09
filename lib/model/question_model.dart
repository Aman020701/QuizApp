
import 'package:equatable/equatable.dart';

class Question extends Equatable{

  final String category;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> answers;

  const Question({

    required this.category,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.answers
});

  @override
  // TODO: implement props
  List<Object?> get props => [
    category,
    difficulty,
    question,
    correctAnswer,
    answers
  ];

  factory Question.fromMap(Map<String,dynamic> ? map){
    if(map == null) {

      // return empty class instance
      return Question(
        category: '',
        difficulty: '',
        question: '',
        correctAnswer: '',
        answers: [],
       );
    }
    return Question(
        category: map['category'] ?? '',
        difficulty: map['difficulty'] ?? '',
        question: map['question'] ?? '',
        correctAnswer: map['correct_answer'] ?? '',
        answers: List <String>.from(map['incorrect answer'] ?? [])
        .. add(map['correct_answer'] ?? '') // add correct answer to list of incorrect answer
        .. shuffle(), // shuffle the list
    );
  }

}