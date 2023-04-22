import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:quizzapp/controllers/quiz/quiz_controller.dart';
import 'package:quizzapp/controllers/quiz/quiz_state.dart';
import 'package:quizzapp/enums/difficulty.dart';
import 'package:quizzapp/model/failure_model.dart';
import 'package:quizzapp/model/question_model.dart';
import 'package:quizzapp/repositories/quiz/quiz_repositories.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html_character_entities/html_character_entities.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
     (ref) => ref.watch(quizRepositoryProvider).getQuestions(
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
              data: (questions) => _buildBody(context, pageController,questions),
              error:(error,_) => QuizError(
                message: error is Failure ? error.message : 'Something went wrong'
              ),
              loading: () => const Center(child: CircularProgressIndicator());
          ),
    ),
    );
  }
}

class QuizError extends StatelessWidget{

  final String message;

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
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(height: 20.0),
          CustomButtom(
           title : 'Retry',
           onTap: () => context.refresh(quizRepositoryProvider),
           ),
        ],
      ),
    );
  }


}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
