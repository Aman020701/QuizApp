// tells us about quiz difficulty , number of question

import 'package:quizzapp/model/question_model.dart';
import '../../enums/difficulty.dart';

abstract class BaseQuizRepository {
  Future <List <Question>> getQuestions ({
    required int numQuestions,
    required int categoryId,
    required Difficulty difficulty,
});
}