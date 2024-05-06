import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Методи працюють але потірбно багато чого доробити

// Future<void> removeFromAllLists(
//     BuildContext context, int filmId, String exceptList) async {
//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     final userRef =
//         FirebaseFirestore.instance.collection('Users').doc(user?.uid);

//     final allLists = ['WatchedMovies', 'PlannedMovies', 'AbandonedMovies'];

//     await Future.forEach(allLists, (listName) async {
//       if (listName != exceptList) {
//         final snapshot = await userRef
//             .collection(listName)
//             .where('filmID', isEqualTo: filmId)
//             .get();
//         snapshot.docs.forEach((doc) {
//           doc.reference.delete();
//         });
//       }
//     });
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content:
//             Text('Помилка під час видалення фільму зі списків користувача'),
//       ),
//     );
//   }
// }

Future<bool> addToUserList(
    BuildContext context, String listName, int filmId) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user?.uid);

    final snapshot = await userRef
        .collection(listName)
        .where('filmID', isEqualTo: filmId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Цей фільм вже існує в обраному списку'),
        ),
      );
      return false;
    }
    await removeFromAllList(context, filmId);

    await userRef.collection(listName).add({
      'filmID': filmId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Фільм успішно додано до списку'),
      ),
    );
    return true;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Помилка під час додавання фільму до списку користувача'),
      ),
    );
    return false;
  }
}

Future<bool> addToWatchedList(BuildContext context, int filmId) async {
  return await addToUserList(context, 'WatchedMovies', filmId);
}

Future<bool> addToPlannedList(BuildContext context, int filmId) async {
  return await addToUserList(context, 'PlannedMovies', filmId);
}

Future<bool> addToAbandonedList(BuildContext context, int filmId) async {
  return await addToUserList(context, 'AbandonedMovies', filmId);
}

Future<void> removeFromAllList(BuildContext context, int movieId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);

    try {
      final lists = ['WatchedMovies', 'PlannedMovies', 'AbandonedMovies'];

      for (var listName in lists) {
        await userRef
            .collection(listName)
            .where('filmID', isEqualTo: movieId)
            .get()
            .then((snapshot) {
          snapshot.docs.forEach((doc) async {
            await doc.reference.delete();
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Помилка під час видалення фільму зі списків користувача'),
        ),
      );
    }
  }
}
