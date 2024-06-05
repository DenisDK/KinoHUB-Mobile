import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kinohub/API%20service/genre_class.dart';
import 'package:kinohub/API%20service/movie_class.dart';
import 'package:kinohub/auth/sing_in_with_google.dart';
import 'package:kinohub/components/alert_dialog_custom.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/routes/routes.dart';
import 'package:kinohub/views/movie_detail_view.dart';
import '../components/bottom_appbar_custom.dart';
import 'package:http/http.dart' as http;

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late List<Genre> genres = [];
  Map<int, List<Movie>> genreMovies = {};
  Map<int, int> pageNumbers = {};
  bool isLoading = false;
  Set<int> displayedMovies = {};
  final int initialMoviesCount = 3;
  int additionalMoviesCount = 5;
  final excludedGenres = [
    'Вестерн',
    'Музика',
    'Телефільм',
    'Історичний',
    'Пригоди',
    'Військовий',
    'Документальний',
    'Мелодрама',
    'Драма',
  ];

  @override
  void initState() {
    super.initState();
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://api.themoviedb.org';
      final response = await http.get(
        Uri.parse('$baseUrl/3/genre/movie/list?api_key=$apiKey&language=uk-UA'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<Genre> fetchedGenres = [];

        for (var genre in jsonData['genres']) {
          if (!excludedGenres.contains(genre['name'])) {
            fetchedGenres.add(Genre(id: genre['id'], name: genre['name']));
          }
        }

        setState(() {
          genres = fetchedGenres;
        });

        for (var genre in fetchedGenres) {
          pageNumbers[genre.id] = 1;
          await fetchMoviesForGenreWithRetry(genre.id, initialMoviesCount);
        }
      } else {
        throw Exception('Failed to load genres');
      }
    } catch (e) {
      throw Exception('Error fetching genres: $e');
    }
  }

  Future<void> fetchMoviesForGenreWithRetry(int genreId, int movieCount) async {
    bool found = false;
    int attempts = 0;

    while (!found && attempts < 10) {
      attempts++;
      int page = getRandomPageNumber();
      List<Movie> movies = await fetchMoviesByGenre(genreId, page);

      if (movies.length >= movieCount) {
        setState(() {
          genreMovies[genreId] = [
            ...(genreMovies[genreId] ?? []),
            ...movies.take(movieCount)
          ];
          pageNumbers[genreId] = page + 1;
        });
        found = true;
      }
    }

    if (!found) {
      setState(() {
        genreMovies[genreId] = [];
      });
    }
  }

  Future<List<Movie>> fetchMoviesByGenre(int genreId, int page) async {
    try {
      String apiKey = dotenv.env['API_KEY'] ?? '';
      const baseUrl = 'https://api.themoviedb.org';
      final response = await http.get(
        Uri.parse(
            '$baseUrl/3/discover/movie?api_key=$apiKey&language=uk-UA&page=$page&with_genres=$genreId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<Movie> fetchedMovies = [];

        for (var movie in jsonData['results']) {
          if ((movie['original_language'] == 'en' ||
                  movie['original_language'] == 'uk') &&
              !displayedMovies.contains(movie['id'])) {
            fetchedMovies.add(Movie(
              id: movie['id'],
              title: movie['title'],
              poster: movie['poster_path'],
            ));
            displayedMovies.add(movie['id']);
          }
        }
        return fetchedMovies;
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      return [];
    }
  }

  int getRandomPageNumber() {
    final random = Random();
    return random.nextInt(100) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF262626),
        title: Row(
          children: [
            Image.asset(
              'lib/images/logo.png',
              height: 35,
              width: 35,
            ),
            const SizedBox(width: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Roboto',
                ),
                children: [
                  TextSpan(
                    text: 'Kino',
                    style: TextStyle(
                      color: Color(0xFFD3D3D3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'HUB',
                    style: TextStyle(
                      color: Color(0xFFFF5200),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Color(0xFFDEDEDE),
            ),
            onPressed: () {
              _handleSignOut(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: genres.map((genre) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    genre.name,
                    style: const TextStyle(
                      color: Color(0xFFDEDEDE),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (genreMovies[genre.id]?.length ?? 0) + 1,
                    itemBuilder: (context, index) {
                      if (index == (genreMovies[genre.id]?.length ?? 0)) {
                        return GestureDetector(
                          onTap: () {
                            fetchMoviesForGenreWithRetry(
                                genre.id, additionalMoviesCount);
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.refresh,
                                color: Color(0xFFDEDEDE),
                              ),
                            ),
                          ),
                        );
                      }
                      final movie = genreMovies[genre.id]?[index];
                      return movie != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    builder: (context) =>
                                        MovieDetailScreen(movieId: movie.id),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'movie_${movie.id}',
                                child: Container(
                                  width: 160,
                                  margin: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.grey[900],
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            'https://image.tmdb.org/t/p/w500${movie.poster}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          movie.title,
                                          style: const TextStyle(
                                            color: Color(0xFFDEDEDE),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        selectedIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  void _handleSignOut(BuildContext context) async {
    bool? result = await CustomDialogAlert.showConfirmationDialog(
      context,
      'Вихід з аккаунту',
      'Ви впевнені, що хочете вийти з аккаунту?',
    );
    if (result != null && result) {
      bool isUserSignOut = await signOut();
      if (isUserSignOut) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не вдалося вийти з аккаунту'),
        ),
      );
    }
  }
}
