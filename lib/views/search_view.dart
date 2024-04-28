import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kinohub/views/movie_detail_view.dart';
import 'package:kinohub/API%20service/movie_class.dart';

const apiKey = '13e8cb10efd590bd45c6a7bd2262db14';
const baseUrl = 'https://api.themoviedb.org/3/search/movie';

class MovieSearchScreen extends StatefulWidget {
  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  List<Movie> movies = [];
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchMovies(String query) async {
    final response =
        await http.get(Uri.https('api.themoviedb.org', '/3/search/movie', {
      'api_key': apiKey,
      'query': query,
      'language': 'uk-UA',
      'page': '1',
    }));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData.containsKey('results')) {
        final response = MovieResponse.fromJson(jsonData);
        setState(() {
          movies = response.results
              .where((movie) =>
                  movie.poster != 'N/A' &&
                  RegExp(r'[а-яА-ЯёЁ]').hasMatch(movie.title))
              .toList();
        });
      } else {
        setState(() {
          movies.clear();
        });
      }
    } else {
      // Handle error if needed
    }
  }

  void debounceFetch(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchMovies(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Пошук фільмів',
          style: TextStyle(color: Color(0xFFDEDEDE), fontSize: 20.0),
        ),
        backgroundColor: const Color(0xFF262626),
        iconTheme: IconThemeData(
          color: Color(0xFFDEDEDE),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Color(0xFFDEDEDE)),
              onChanged: (value) {
                debounceFetch(value);
              },
              decoration: InputDecoration(
                labelText: 'Введіть назву фільму',
                labelStyle: TextStyle(color: Color(0xFFDEDEDE)),
                prefixIcon: Icon(Icons.search, color: Color(0xFFDEDEDE)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: movies.isNotEmpty
                ? ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          color: Colors.grey[800],
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(12.0),
                            title: Text(
                              movies[index].title,
                              style: TextStyle(
                                color: Color(0xFFDEDEDE),
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            leading: movies[index].poster != 'N/A'
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      movies[index].poster,
                                      width: 80.0, // Increased width
                                      height: 120.0, // Increased height
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 80.0, // Increased width
                                    height: 120.0, // Increased height
                                    decoration: BoxDecoration(
                                      color: Colors.grey[600],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Color(0xFFDEDEDE),
                                      size: 30.0,
                                    ),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailScreen(
                                      movieId: movies[index].id),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Немає результатів пошуку',
                      style:
                          TextStyle(color: Color(0xFFDEDEDE), fontSize: 16.0),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class MovieResponse {
  final List<Movie> results;

  MovieResponse({required this.results});

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      results: (json['results'] as List).map((item) {
        if (item.containsKey('id')) {
          return Movie(
            id: item['id'],
            title: item['title'],
            poster:
                item.containsKey('poster_path') && item['poster_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}'
                    : 'N/A',
          );
        } else {
          // Handle case when id is missing from API response
          return Movie(
            id: 0, // Assign a default value or handle it according to your logic
            title: item['title'],
            poster:
                item.containsKey('poster_path') && item['poster_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}'
                    : 'N/A',
          );
        }
      }).toList(),
    );
  }
}
