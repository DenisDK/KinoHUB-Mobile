// Метод для додавання фільму до вибраного списку користувача
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Методи працюють але потірбно багато чого доробити
Future<void> addToUserList(
    BuildContext context, String listName, int filmId) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user?.uid);

    // Перевірка, чи існує фільм з таким ідентифікатором у вибраному списку користувача
    final snapshot = await userRef
        .collection(listName)
        .where('filmID', isEqualTo: filmId)
        .get();

    // Якщо документ з таким ідентифікатором вже існує, повідомлення про це
    if (snapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Цей фільм вже існує в обраному списку'),
        ),
      );
      return;
    }

    // Якщо фільму з таким ідентифікатором немає у списку, додаємо його
    await userRef.collection(listName).add({
      'filmID': filmId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Якщо додавання успішне, показуємо повідомлення про це
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Фільм успішно додано до списку'),
      ),
    );
  } catch (e) {
    print('Помилка під час додавання фільму до списку користувача: $e');
  }
}

// Функція, яка викликається при виборі дії користувачем (додати до списку переглянутих)
void addToWatchedList(BuildContext context, int filmId) {
  addToUserList(context, 'WatchedMovies', filmId);
}

// Функція, яка викликається при виборі дії користувачем (додати до списку запланованих)
void addToPlannedList(BuildContext context, int filmId) {
  addToUserList(context, 'PlannedMovies', filmId);
}

// Функція, яка викликається при виборі дії користувачем (додати до списку покинутих)
void addToAbandonedList(BuildContext context, int filmId) {
  addToUserList(context, 'AbandonedMovies', filmId);
}
