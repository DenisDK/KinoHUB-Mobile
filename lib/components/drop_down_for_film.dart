// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';

class CustomPopupMenu {
  static const String viewed = 'Переглянутих';
  static const String planned = 'Запланованих';
  static const String abandoned = 'Покинутих';

  static const List<String> choices = <String>[
    viewed,
    planned,
    abandoned,
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
            borderRadius: BorderRadius.circular(15.0),
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

void showPopupMenuForMovie(BuildContext context) async {
  String? choice = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(1000, 285, 0, 0), // Позиція меню
    color: Color.fromARGB(255, 48, 48, 48), // Колір фону меню і колір кнопок
    items: CustomPopupMenu.choices.map((String choice) {
      return PopupMenuItem<String>(
        value: choice,
        child: CustomPopupMenuItem(
          text: choice,
          onTap: () {
            if (choice == CustomPopupMenu.viewed) {
              // Ваш код для обробки вибору "Профіль"
            } else if (choice == CustomPopupMenu.planned) {
              // Ваш код для обробки вибору "Преміум"
            } else if (choice == CustomPopupMenu.abandoned) {
              // Ваш код для виклику функції виходу з аккаунту
            }
          },
        ),
      );
    }).toList(),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0), // Закруглення країв
    ),
  );
}
