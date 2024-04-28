import 'package:flutter/material.dart';

class CustomDialogAlert {
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800], // Колір фону (темна тема)
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFDEDEDE), // Колір тексту заголовку
              fontFamily: 'Roboto',
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              color: Color(0xFFDEDEDE), // Колір тексту контенту
              fontFamily: 'Roboto',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Ні',
                style: TextStyle(
                  color: Color(0xFFDEDEDE), // Колір тексту кнопки "Ні"
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Так',
                style: TextStyle(
                  color: Color(0xFFDEDEDE), // Колір тексту кнопки "Так"
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
