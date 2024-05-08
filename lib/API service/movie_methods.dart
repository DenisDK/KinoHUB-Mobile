import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kinohub/API%20service/movie_class.dart';
import 'package:url_launcher/url_launcher.dart';

Future<String> checkLanguageAvailability(
    String text,
    int movieId,
    String language,
    String fallbackLanguage,
    String apiKey,
    String baseUrl) async {
  if (text.isEmpty) {
    final responseEn = await http.get(
      Uri.parse('$baseUrl/$movieId?api_key=$apiKey&language=$fallbackLanguage'),
    );

    if (responseEn.statusCode == 200) {
      final jsonDataEn = json.decode(responseEn.body);
      return jsonDataEn['overview'] ?? '';
    } else {
      throw Exception('Помилка при завантаженні даних про фільм');
    }
  }
  return text;
}

Future<DetailedMovie> fetchMovieDetails(int movieId) async {
  String apiKey = dotenv.env['API_KEY'] ?? '';
  const baseUrl = 'https://api.themoviedb.org/3/movie';
  const defaultLanguage = 'uk-UA';
  const fallbackLanguage = 'en-US';

  try {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/$movieId?api_key=$apiKey&language=$defaultLanguage&append_to_response=release_dates,production_countries'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final releaseDate = DateTime.parse(jsonData['release_date']);
      final releaseYear = releaseDate.year;

      final directorResponse = await http.get(
        Uri.parse('$baseUrl/$movieId/credits?api_key=$apiKey'),
      );
      String director = '';
      if (directorResponse.statusCode == 200) {
        final creditsJson = json.decode(directorResponse.body);
        final List<dynamic> crew = creditsJson['crew'];
        final directorData = crew.firstWhere(
          (person) => person['job'] == 'Director',
          orElse: () => null,
        );
        director = directorData != null ? directorData['name'] : '';
      }

      String certification = '';
      final releaseDates = jsonData['release_dates']['results'];
      for (var result in releaseDates) {
        if (result['iso_3166_1'] == 'US') {
          certification = result['release_dates'][0]['certification'];
          break;
        }
      }

      List<String> productionCountries = [];
      final countries = jsonData['production_countries'];
      for (var country in countries) {
        productionCountries.add(country['name']);
      }

      String productionStudio = '';
      final studios = jsonData['production_companies'];
      if (studios.isNotEmpty) {
        productionStudio = studios[0]['name'];
      }

      String overview = await checkLanguageAvailability(jsonData['overview'],
          movieId, defaultLanguage, fallbackLanguage, apiKey, baseUrl);

      return DetailedMovie(
        id: jsonData['id'],
        title: jsonData['title'],
        poster: 'https://image.tmdb.org/t/p/w500${jsonData['poster_path']}',
        overview: overview.isNotEmpty ? overview : 'Інформація не знайдена',
        rating: jsonData['vote_average'],
        genres: jsonData['genres'] != null
            ? List<String>.from(
                jsonData['genres'].map((genre) => genre['name']))
            : [],
        releaseYear: releaseYear,
        director: director,
        certification: certification,
        productionCountries: productionCountries,
        productionStudio: productionStudio,
      );
    } else {
      throw Exception('Помилка при завантаженні даних про фільм');
    }
  } catch (e) {
    throw Exception('Помилка при завантаженні даних про фільм: $e');
  }
}

Future<String> fetchMovieTrailer(int movieId) async {
  try {
    String apiKey = dotenv.env['API_KEY'] ?? '';
    const baseUrl = 'https://api.themoviedb.org/3/movie';

    final response = await http.get(
      Uri.parse('$baseUrl/$movieId/videos?api_key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'];

      for (var video in results) {
        if (video['type'] == 'Trailer') {
          return 'https://www.youtube.com/watch?v=${video['key']}';
        }
      }

      throw Exception('Трейлер не знайдено');
    } else {
      throw Exception('Помилка при завантаженні трейлера');
    }
  } catch (e) {
    throw Exception('Помилка при отриманні трейлера: $e');
  }
}

void launchURL(String url, context) async {
  final Uri _url = Uri.parse(url);
  if (await canLaunchUrl(_url)) {
    await launchUrl(_url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Помилка при завантаженні трейлера'),
      ),
    );
  }
}
