// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';

class CustomPopupMenu {
  static const String viewed = 'Переглянутих';
  static const String planned = 'Запланованих';
  static const String abandoned = 'Покинутих';
  static const String delete = 'Видалити';

  static const List<String> choices = <String>[
    viewed,
    planned,
    abandoned,
    delete,
  ];
}

class CustomPopupMenuItem extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const CustomPopupMenuItem({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: const Color(0xFF464646), // Колір обрамлення
              width: 2.0, // Ширина обрамлення
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFDEDEDE), // Колір тексту
              ),
            ),
          ),
        ),
      ),
    );
  }
}
