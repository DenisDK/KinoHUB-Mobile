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
          backgroundColor: Color.fromARGB(255, 175, 175, 175), // Колір фону
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black, // Колір тексту заголовку
              fontFamily: 'Roboto',
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.black, // Колір тексту контенту
              fontFamily: 'Roboto',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Ні',
                style: TextStyle(
                  color: Colors.black, // Колір тексту кнопки ні
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Так',
                style: TextStyle(
                  color: Colors.black, // Колір тексту кнопки так
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
