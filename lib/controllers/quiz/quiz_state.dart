
import 'package:equatable/equatable.dart';

import '../../model/question_model.dart';

enum QuizStatus {initial,correct,incorrect,complete}

class QuizState extends Equatable{

  final String seletedAnswer;
  final List<Question> correct;
  final List<Question> incorrect;
  final QuizStatus status;

  bool get answered => status == QuizStatus.incorrect || status == QuizStatus.correct;

  const QuizState({
    required this.seletedAnswer,
    required this.correct,
    required this.incorrect,
    required this.status,
});

  factory QuizState.initial(){
    return QuizState(
      seletedAnswer: '',
      correct: [],
      incorrect: [],
      status: QuizStatus.initial,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    seletedAnswer,
    correct,
    incorrect,
    status
  ];

  QuizState copyWith ({

    String? seletedAnswer,
    List<Question>? correct,
    List<Question>? incorrect,
    QuizStatus? status,

}) {
    return QuizState(
        seletedAnswer: seletedAnswer ?? this.seletedAnswer,
        correct: correct ?? this.correct,
        incorrect: incorrect ?? this.incorrect,
        status: status ?? this.status
    );
  }
}