import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<List<int>> getWatchedMoviesIds() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);

    try {
      final snapshot = await userRef.collection('WatchedMovies').get();
      final List<int> watchedMovieIds = [];

      snapshot.docs.forEach((doc) {
        watchedMovieIds.add(doc['filmID'] as int);
      });

      return watchedMovieIds;
    } catch (e) {
      print('Error fetching watched movie IDs: $e');
      return [];
    }
  } else {
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchMoviesByIds(List<int> movieIds) async {
  List<Map<String, dynamic>> moviesData = [];
  String apiKey = dotenv.env['API_KEY'] ?? '';

  for (int movieId in movieIds) {
    try {
      final response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=uk-UA'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final poster = jsonData['poster_path'] != null
            ? 'https://image.tmdb.org/t/p/w500${jsonData['poster_path']}'
            : 'N/A';
        final title = jsonData['title'];

        moviesData.add({
          'poster': poster,
          'title': title,
          'id': movieId,
        });
      } else {
        print('Error loading data for movie $movieId');
      }
    } catch (e) {
      print('Error loading data for movie $movieId: $e');
    }
  }

  return moviesData;
}

Future<List<Map<String, dynamic>>> watchedMovies() async {
  List<int> watchedMovieIds = await getWatchedMoviesIds();

  return fetchMoviesByIds(watchedMovieIds);
}
