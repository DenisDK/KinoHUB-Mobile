import 'package:flutter/material.dart';

class CustomDialogAlert {
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AlertDialog(
          backgroundColor: Colors.grey[800], 
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFDEDEDE), 
              fontFamily: 'Roboto',
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              color: Color(0xFFDEDEDE), 
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
                  color: Color.fromARGB(
                      255, 242, 111, 50),
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
                  color: Color.fromARGB(
                      255, 242, 111, 50),
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
