import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_quiz/widgets/close_button.dart';
import 'package:bloc_quiz/widgets/option_widget.dart';
import 'package:bloc_quiz/bloc/quiz/quiz_bloc.dart';
import 'package:bloc_quiz/bloc/quiz/quiz_event.dart';
import 'package:bloc_quiz/bloc/quiz/quiz_state.dart';
import 'package:bloc_quiz/presentation/main/result_detail_screen.dart';
import 'package:bloc_quiz/utility/prepare_quiz.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    Key? key,
    required this.questionData,
    required this.categoryIndex,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.isMarathon,
  }) : super(key: key);

  final questionData;
  final int categoryIndex;
  final String difficultyLevel;
  final int numQuestions;
  final bool isMarathon;

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  late PrepareQuiz quizMaker;
  late QuizBloc _quizBloc;
  bool _isLoading = true;
  bool isAbsorbing = false;
  int selectedOption = -1;

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  Timer? _timer;
  int _remainingTime = 4800;
  int _elapsedTime = 0;

  @override
  void initState() {
    super.initState();
    quizMaker = PrepareQuiz();
    _quizBloc = QuizBloc(quizMaker, widget.numQuestions == 800);
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    await _loadQuestions();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _quizBloc.add(StartQuiz());
      });
    }
    if (widget.numQuestions == 70) {
      _startTimer();
    }
    if (widget.numQuestions == 800) {
      _startStopwatch();
    }
  }

  Future<void> _loadQuestions() async {
    await quizMaker.populateList(numQuestions: widget.numQuestions);
    print('Загружено ${quizMaker.getTotalQuestions()} вопросов');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _navigateToResultScreen(context, _quizBloc.state);
        }
      });
    });
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _quizBloc.close();
    _scrollController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showClarificationBottomSheet(String clarificationText) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      // barrierLabel: 'Пояснение',
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Пояснение', // Ваш постоянный заголовок
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                clarificationText,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _quizBloc,
      child: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizFinishedState) {
            _navigateToResultScreen(context, state);
          }
        },
        child: Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : BlocBuilder<QuizBloc, QuizState>(
            builder: (context, state) {
              if (state is QuizOnGoingState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToQuestion(state.currentIndex);
                });
                return AbsorbPointer(
                  absorbing: isAbsorbing,
                  child: buildQuizUI(state),
                );
              }
              return const Center(child: Text('Загрузка...'));
            },
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80.0), // например, поднимем кнопку на 80 пикселей
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizOnGoingState) {
                  final clarificationText = state.clarifications[state.currentIndex];
                  return FloatingActionButton(
                    onPressed: () {
                      _showClarificationBottomSheet(clarificationText!);
                    },
                    child: const Icon(Icons.help_outline),
                  );
                }
                return Container();
              },
            ),
          ),

        ),
      ),
    );
  }

  Widget buildQuizUI(QuizOnGoingState state) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 60, bottom: 20),
      decoration: BoxDecoration(
        //color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildHeader(state),
          Expanded(
            child: buildQuestionAndOptions(state),
          ),
          const SizedBox(height: 20),
          buildNavigationButtons(state),
        ],
      ),
    );
  }

  Widget buildHeader(QuizOnGoingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const RoundCloseButton(),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              itemCount: state.totalQuestions,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 33,
                    height: 33,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.currentIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: state.currentIndex == index
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildQuestionAndOptions(QuizOnGoingState state) {
    if (state.questions.isEmpty) {
      return const Center(child: Text('Нет доступных вопросов'));
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: state.totalQuestions,
      onPageChanged: (index) {
        _quizBloc.add(JumpToQuestion(index));
      },
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          child: Column(
            children: [
              buildQuestionText(state, index),
              buildOptionSection(state, index),
            ],
          ),
        );
      },
    );
  }

  Widget buildQuestionText(QuizOnGoingState state, int index) {
    final question = state.questions[index] as Map<String, dynamic>;
    return Card(
      elevation: 0,
      //color: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${index + 1} из ${state.totalQuestions}',
                    style: TextStyle(
                      //color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  if (widget.numQuestions == 70)
                    Text(
                      _formatTime(_remainingTime),
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  if (widget.numQuestions == 800)
                    Text(
                      _formatTime(_elapsedTime),
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                question['questionText'] as String,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionSection(QuizOnGoingState state, int index) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            children: buildOptions(state.allOptions[index], index),
          ),
        ),
      ),
    );
  }

  List<Widget> buildOptions(List<String> options, int questionIndex) {
    return List.generate(
      options.length,
          (j) => BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizOnGoingState) {
            return OptionWidget(
              widget: widget,
              option: options[j],
              optionColor: state.selectedOptions[questionIndex] == j
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
              onTap: () {
                setState(() {
                  _quizBloc.add(AnswerSelected(questionIndex, j));
                });
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget buildNavigationButtons(QuizOnGoingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            if (state.currentIndex > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            //backgroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(50, 50),
          ),
          child: const Icon(Icons.arrow_back),
        ),
        ElevatedButton(
          onPressed: () => _navigateToResultScreen(context, state),
          style: ElevatedButton.styleFrom(
            elevation: 3,
            //backgroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(100, 50),
          ),
          child: const Text('Закончить попытку'),
        ),
        ElevatedButton(
          onPressed: () {
            if (state.currentIndex < state.totalQuestions - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              _quizBloc.add(QuizFinished(selectedOption));
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 3,
            //backgroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(50, 50),
          ),
          child: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  void _navigateToResultScreen(BuildContext context, QuizState state) {

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultDetailScreen(
          score: state.currentScore,
          categoryIndex: widget.categoryIndex,
          attempts: state.currentAttempts,
          wrongAttempts: state.currentWrongAttempts,
          correctAttempts: state.currentCorrectAttempts,
          //difficultyLevel: widget.difficultyLevel,
          isSaved: false,
          questions: state.questions,


        ),
      ),
    );
  }

  void _scrollToQuestion(int index) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final itemExtent = size.width / 8.4;

    final targetScrollOffset = (index * itemExtent) - (size.width / 2) + (itemExtent / 2);

    _scrollController.animateTo(
      targetScrollOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}