// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import '../auth/sing_in_with_google.dart';
import '../routes/routes.dart';
import 'alert_dialog_custom.dart';

class CustomPopupMenu {
  static const String profile = 'Профіль';
  static const String premium = 'Преміум';
  static const String settings = 'Налаштування';
  static const String signOut = 'Вихід';

  static const List<String> choices = <String>[
    profile,
    premium,
    settings,
    signOut,
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

void showPopupMenu(BuildContext context) async {
  String? choice = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(1000, 50, 0, 0), // Позиція меню
    color: Color.fromARGB(255, 48, 48, 48), // Колір фону меню і колір кнопок
    items: CustomPopupMenu.choices.map((String choice) {
      return PopupMenuItem<String>(
        value: choice,
        child: CustomPopupMenuItem(
          text: choice,
          onTap: () {
            if (choice == CustomPopupMenu.profile) {
              // Ваш код для обробки вибору "Профіль"
            } else if (choice == CustomPopupMenu.premium) {
              // Ваш код для обробки вибору "Преміум"
            } else if (choice == CustomPopupMenu.settings) {
              // Ваш код для обробки вибору "Налаштування"
            } else if (choice == CustomPopupMenu.signOut) {
              // Ваш код для виклику функції виходу з аккаунту
              _handleSignOut(context);
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

void _handleSignOut(BuildContext context) async {
  bool? result = await CustomDialogAlert.showConfirmationDialog(
    context,
    'Вихід з аккаунту',
    'Ви впевнені, що хочете вийти з аккаунту?',
  );
  if (result != null && result) {
    bool isUserSignOut = await signOut();
    if (isUserSignOut) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        loginRoute,
        (route) => false,
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Не вдалося вийти з аккаунту'),
      ),
    );
  }
}
