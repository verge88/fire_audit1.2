import 'package:flutter/material.dart';

class RoundCloseButton extends StatelessWidget {
  const RoundCloseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Icon(
        Icons.close,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// void _showDialog(BuildContext context, String title, int numQuestions) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Center(child: Text(title)),
//         content: Container(
//           height: 150,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text('Количество вопросов: $numQuestions', style: TextStyle(fontSize: 18),),
//               Text('Время на выполнение: 80 мин', style: TextStyle(fontSize: 18),), // Замените на соответствующее значение
//               Text('Минимум правильных ответов: 60', style: TextStyle(fontSize: 18),), // Замените на соответствующее значение
//             ],
//           ),
//
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Начать'),
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).push(MaterialPageRoute(builder: (context) => PrepareQuizScreen(
//                 //index: title == 'Экзамен' ? 0 : 1,
//                 selectedDif: '',
//                 numQuestions: numQuestions,
//               )));
//             },
//           ),
//         ],
//       );
//     },
//   );
//
//
// }