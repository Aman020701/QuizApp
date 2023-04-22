import 'dart:io';
import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quizzapp/enums/difficulty.dart';
import 'package:quizzapp/model/question_model.dart';
import 'package:quizzapp/repositories/quiz/base_quiz_repositories.dart';
import '../../model/failure_model.dart';


final dioProvider = Provider((ref) => Dio());
final quizRepositoryProvider = Provider<QuizRepository>((ref) => QuizRepository(ref.read));

class QuizRepository extends BaseQuizRepository{

   final Reader _read;

   QuizRepository(this._read);

  @override
  Future<List<Question>> getQuestions({
    required int numQuestions,
    required int categoryId,
    required Difficulty difficulty}) async{
    try{
      final queryParameter = {
        'type' : 'multiple',
        'amount' : numQuestions,
        'category' : categoryId,
      };
      if(difficulty != Difficulty.any){
        queryParameter.addAll(
         {'difficulty' : EnumToString.convertToString(difficulty)},
        );
      }
      final response = await _read(dioProvider).get(
        'https://opentdb.com/api.php',
         queryParameter : queryParameter,
      );

      if(response.statusCode == 200){
        final data = Map<String,dynamic>.from(response.data);
        final results = List<Map<String,dynamic>>.from(data['results'] ?? []);
        if(results.isNotEmpty){
          return results.map((e) => Question.fromMap(e)).toList();
        }
      }
      return [];
    } on DioError catch (err){
      print(err);
      throw  Failure(message: err.response?.statusMessage);
    } on SocketException catch (err){
      print(err);
      throw const Failure(message: 'Please check your connection');
    }
  }
   
}