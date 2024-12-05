import 'package:flutter/material.dart';
import 'package:bloc_quiz/utility/category_detail_list.dart';
import 'package:bloc_quiz/presentation/main/difficulty_selection_screen.dart';

import '../../main/prepare_quiz_screen.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // Добавьте нижний отступ между элементами
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrepareQuizScreen(
                index: index,
                selectedDif: '',
                numQuestions: 800, // Set numQuestions for exam
              )
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
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Экзамен',
                  style: TextStyle(
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
