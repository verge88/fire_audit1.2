import 'package:flutter/material.dart';

class OptionWidget extends StatelessWidget {
  const OptionWidget({
    Key? key,
    required this.widget,
    required this.option,
    required this.optionColor,
    required this.onTap,
  }) : super(key: key);

  final dynamic widget;
  final String option;
  final Color optionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: optionColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: optionColor == Colors.white
                      ? Colors.black
                      : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}