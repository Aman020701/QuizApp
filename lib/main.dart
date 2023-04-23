import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:quizzapp/controllers/quiz/quiz_controller.dart';
import 'package:quizzapp/controllers/quiz/quiz_state.dart';
import 'package:quizzapp/enums/difficulty.dart';
import 'package:quizzapp/model/failure_model.dart';
import 'package:quizzapp/model/question_model.dart';
import 'package:quizzapp/repositories/quiz/quiz_repositories.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Quiz Test',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
        ),
        home: QuizScreen(),
      ),
    );
  }
}


 final quizQuestionsProvider = FutureProvider.autoDispose<List<Question>>(
     (ref) async => ref.watch(quizRepositoryProvider).getQuestions(
         numQuestions: 5,
         categoryId: Random().nextInt(24)+9,
         difficulty: Difficulty.any
     )

 );

class QuizScreen extends HookConsumerWidget{

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final quizQuestions = ref.watch(quizQuestionsProvider);
    final pageController = usePageController();
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFD4418E),Color(0xFF0652C5)],
            begin: Alignment.topLeft,
            end : Alignment.bottomRight,
        )
      ),
        child: Scaffold(
        backgroundColor: Colors.transparent,
          body: quizQuestions.when(
              data: (questions) => _buildBody(context, pageController,questions,ref),
              error:(error,_) => QuizError(
                message: error is Failure ? error.message : 'Something went wrong'
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
          ),
    ),
    );
  }

      Widget _buildBody(BuildContext context,PageController pageController,List<Question>questions,WidgetRef ref){

        if(questions.isEmpty) return QuizError(message: 'No questions found');

        final quizState = ref.read(quizControllerProvider.state);
        return quizState.status == QuizStatus.complete
            ? QuizResults(state:quizState,questions:questions)
            : QuizQuestions(
              pageController : pageController,
              state : quizState,
              questions: questions,
             );
      }

 }

class QuizError extends ConsumerWidget {

  final String? message;

  const QuizError({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 20.0),
          CustomButtom(
            title: 'Retry',
            onTap: () => ref.refresh(quizRepositoryProvider),
          ),
        ],
      ),
    );
  }
}

final List <BoxShadow> boxShadow = const[
  BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 2),
    blurRadius: 4.0,
  ),
];

class CustomButtom extends StatelessWidget{

  final String title;
  final VoidCallback onTap;

  const CustomButtom({
    Key? key,
    required this.title,
    required this.onTap,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.yellow[700],
          boxShadow: boxShadow,
          borderRadius: BorderRadius.circular(25.0),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

}

class QuizResults extends ConsumerWidget {

  final QuizState state;
  final List <Question> questions;

  const QuizResults ({
    Key? key,
    required this.state,
    required this.questions
 }) : super (key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
   return Column(
     mainAxisAlignment: MainAxisAlignment.center,
     crossAxisAlignment: CrossAxisAlignment.stretch,
     children: [
       Text(
       '${state.correct.length} / ${questions.length}',
         style: const TextStyle(
           color: Colors.white,
           fontSize: 60,
           fontWeight: FontWeight.w600,
         ),
         textAlign: TextAlign.center,
       ),
        const Text(
         'CORRECT',
         style: TextStyle(
           color: Colors.white,
           fontSize: 48,
           fontWeight: FontWeight.bold,
         ),
         textAlign: TextAlign.center,
       ),
       const SizedBox(height: 40.0),
       CustomButtom(title: 'New Quiz', onTap: (){
         ref.refresh(quizRepositoryProvider);
         ref.read(quizControllerProvider).reset();
         },
       ),
     ],
   );
  }
}

class QuizQuestions extends ConsumerWidget {

  final PageController pageController;
  final QuizState state;
  final List <Question> questions;

  const QuizQuestions ({
  Key ? key,
  required this.pageController,
  required this.state,
  required this.questions,
 }) : super(key : key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return PageView.builder(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (BuildContext context, int index){
        final question = questions[index];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Questions ${index+1} of {questions.length}',
               style: const TextStyle(
                 color: Colors.white,
                 fontSize: 24,
                 fontWeight: FontWeight.bold,
               ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                 child : Text(
                  HtmlCharacterEntities.decode(question.question),
                  style : const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500
                  )
              ),
            ),
            Divider(
              color: Colors.grey[200],
              height: 32.0,
              thickness: 2.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
            Column(
              children: question.answers
                  .map(
                      (e) => AnswerCard(
                        answer : e,
                        isSelected : e == state.seletedAnswer,
                        isCorrect : e == question.correctAnswer,
                        isDisplayingAnswer : state.answered,
                        onTap : () => ref
                          .read(quizControllerProvider)
                          .submitAnswer(question,e)
                      ),
                ).toList(),
            ),
          ],
        );
      }
    );
  }
}

class AnswerCard extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final bool isCorrect;
  final bool isDisplayingAnswer;
  final VoidCallback onTap;

  const AnswerCard({
    Key? key,
    required this.answer,
    required this.isSelected,
    required this.isCorrect,
    required this.isDisplayingAnswer,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 20.0,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 20.0,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: boxShadow,
          border: Border.all(
            color: isDisplayingAnswer
                ? isCorrect
                ? Colors.green
                : isSelected
                ? Colors.red
                : Colors.white
                : Colors.white,
            width: 4.0,
          ),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                HtmlCharacterEntities.decode(answer),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: isDisplayingAnswer && isCorrect
                      ? FontWeight.bold
                      : FontWeight.w400,
                ),
              ),
            ),
            if (isDisplayingAnswer)
              isCorrect
                  ? const CircularIcon(icon: Icons.check, color: Colors.green)
                  : isSelected
                  ? const CircularIcon(
                icon: Icons.close,
                color: Colors.red,
              )
                  : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

class CircularIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CircularIcon({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.0,
      width: 24.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: boxShadow,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16.0,
      ),
    );
  }
}
