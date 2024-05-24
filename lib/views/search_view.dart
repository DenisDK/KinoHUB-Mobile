import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kinohub/API%20service/genre_class.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';
import 'package:kinohub/views/movie_detail_view.dart';
import 'package:kinohub/API%20service/movie_class.dart';
import '../components/custom_page_route.dart';

String apiKey = dotenv.env['API_KEY'] ?? '';
const baseUrl = 'https://api.themoviedb.org/3/search/movie';
const genreUrl = 'https://api.themoviedb.org/3/genre/movie/list';

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  List<Movie> movies = [];
  List<Genre> genres = [];
  late TextEditingController _searchController;
  String? _selectedGenre;
  Timer? _debounce;
  int _currentPage = 1; // Змінна для відстеження поточної сторінки результатів

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedGenre = null;
    fetchGenres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchGenres() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=uk-UA'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        genres = (jsonData['genres'] as List)
            .map((genre) => Genre.fromJson(genre))
            .toList();
      });
    } else {
      throw Exception('Помилка завантаження жанрів');
    }
  }

  Future<void> fetchMovies(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&language=uk-UA&page=1'));

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
      throw Exception('Помилка завантаження даних');
    }
  }

  Future<void> fetchMoviesByGenre(String genreId, int page) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&with_genres=$genreId&language=uk-UA&page=$page'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData.containsKey('results')) {
        final response = MovieResponse.fromJson(jsonData);
        setState(() {
          if (page == 1) {
            movies = response.results
                .where((movie) =>
                    movie.poster != 'N/A' &&
                    RegExp(r'[а-яА-ЯёЁ]').hasMatch(movie.title))
                .toList();
          } else {
            movies.addAll(response.results
                .where((movie) =>
                    movie.poster != 'N/A' &&
                    RegExp(r'[а-яА-ЯёЁ]').hasMatch(movie.title))
                .toList());
          }
        });
      } else {
        setState(() {
          movies.clear();
        });
      }
    } else {
      throw Exception('Помилка завантаження даних');
    }
  }

  void debounceFetch(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      fetchMovies(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF262626),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    debounceFetch(value);
                  },
                  cursorColor: const Color(0xFFFF5200),
                  decoration: InputDecoration(
                    labelText: 'Пошук за назвою',
                    labelStyle: const TextStyle(color: Color(0xFFDEDEDE)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFFDEDEDE)),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                        fetchMovies('');
                      },
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFDEDEDE)),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.grey[800],
                  value: _selectedGenre,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Пошук за жанром',
                        style: TextStyle(
                            color: Color(0xFFDEDEDE),
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    ...genres.map((genre) {
                      return DropdownMenuItem<String>(
                        value: genre.id.toString(),
                        child: Text(
                          genre.name,
                          style: const TextStyle(color: Color(0xFFDEDEDE)),
                        ),
                      );
                    }),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGenre = newValue;
                      _currentPage = 1;
                      fetchMoviesByGenre(newValue ?? '', _currentPage);
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                    suffixIcon: _selectedGenre != null
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Color(0xFFDEDEDE)),
                            onPressed: () {
                              setState(() {
                                _selectedGenre = null;
                                movies.clear();
                              });
                              fetchMovies('');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: movies.isNotEmpty
                ? ListView.builder(
                    itemCount: movies.length + 1,
                    itemBuilder: (context, index) {
                      if (index == movies.length) {
                        return _buildLoadMoreButton();
                      } else {
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
                              contentPadding: const EdgeInsets.all(12.0),
                              title: Text(
                                movies[index].title,
                                style: const TextStyle(
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
                                        width: 80.0,
                                        height: 120.0,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 80.0,
                                      height: 120.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Color(0xFFDEDEDE),
                                        size: 30.0,
                                      ),
                                    ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    builder: (context) => MovieDetailScreen(
                                        movieId: movies[index].id),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                  )
                : const Center(
                    child: Text(
                      'Немає результатів пошуку',
                      style: TextStyle(
                          color: Color.fromARGB(255, 154, 154, 154),
                          fontSize: 16.0),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        selectedIndex: 1,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
        child: ElevatedButton(
          onPressed: () {
            _currentPage++;
            fetchMoviesByGenre(_selectedGenre ?? '', _currentPage);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF242729),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            minimumSize: const Size(150, 0),
          ),
          child: const Text(
            'Завантажити ще',
            style: TextStyle(
              color: Color(0xFFDEDEDE),
            ),
          ),
        ),
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
          return Movie(
            id: 0,
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
