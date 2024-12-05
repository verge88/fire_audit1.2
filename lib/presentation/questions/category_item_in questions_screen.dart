import 'package:bloc_quiz/presentation/questions/questions_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:bloc_quiz/bloc/quiz_data/quiz_data_state.dart';
import 'package:bloc_quiz/utility/category_detail_list.dart';
import 'package:bloc_quiz/presentation/main/difficulty_selection_screen.dart';

import 'package:flutter/material.dart';
import 'package:bloc_quiz/utility/category_detail_list.dart';
import 'questions_list_screen.dart';

class CategoryItemInQuestionsScreen extends StatelessWidget {
  final String selectedDif;
  final int index;

  const CategoryItemInQuestionsScreen(this.index, this.selectedDif);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionsListScreen(
                categoryIndex: index,
                difficultyLevel: selectedDif,
              ),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: categoryDetailList[index].accentColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  categoryDetailList[index].title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

