import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<List<int>> getWatchedFromIds(String userCollection, String userId) async {
  final String collection = userCollection;
  final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);

  try {
    final snapshot = await userRef.collection(collection).get();
    final List<int> watchedMovieIds = [];

    snapshot.docs.forEach((doc) {
      watchedMovieIds.add(doc['filmID'] as int);
    });

    return watchedMovieIds;
  } catch (e) {
    return [];
  }
}


Future<List<Map<String, dynamic>>> fetchMoviesByIds(List<int> movieIds) async {
  List<Future<Map<String, dynamic>>> fetchFutures = [];

  String apiKey = dotenv.env['API_KEY'] ?? '';
  for (int movieId in movieIds) {
    if (movieId != 0) {
      fetchFutures.add(fetchMovie(movieId, apiKey));
    }
  }

  List<Map<String, dynamic>> moviesData = await Future.wait(fetchFutures);
  return moviesData;
}

Future<Map<String, dynamic>> fetchMovie(int movieId, String apiKey) async {
  try {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=uk-UA'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final poster = jsonData['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${jsonData['poster_path']}'
          : 'N/A';
      final title = jsonData['title'];

      return {
        'poster': poster,
        'title': title,
        'id': movieId,
      };
    } else {
      return {
        'poster': 'N/A',
        'title': 'Unknown',
        'id': movieId,
      };
    }
  } catch (e) {
    return {
      'poster': 'N/A',
      'title': 'Unknown',
      'id': movieId,
    };
  }
}

Future<List<Map<String, dynamic>>> plannedMovies(String userId) async {
  List<int> plannedMovieIds = await getWatchedFromIds('PlannedMovies', userId);

  return fetchMoviesByIds(plannedMovieIds);
}

Future<List<Map<String, dynamic>>> watchedMovies(String userId) async {
  List<int> watchedMovieIds = await getWatchedFromIds('WatchedMovies', userId);

  return fetchMoviesByIds(watchedMovieIds);
}

Future<List<Map<String, dynamic>>> abandonedMovies(String userId) async {
  List<int> abandonedMovieIds = await getWatchedFromIds('AbandonedMovies', userId);

  return fetchMoviesByIds(abandonedMovieIds);
}

