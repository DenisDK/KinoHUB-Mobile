import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  late List<Movie> movies = [];
  bool isLoading = false;
  int pageNumber = 1;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Доскроллили до конця списку, загрузили нові фільми
      fetchMovies();
    }
  }

  Future<void> fetchMovies() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    String apiKey = dotenv.env['API_KEY'] ?? '';
    const baseUrl = 'https://api.themoviedb.org';
    final response = await http.get(
      Uri.parse(
          '$baseUrl/3/movie/popular?api_key=$apiKey&language=uk-UA&page=$pageNumber'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<Movie> fetchedMovies = [];

      for (var movie in jsonData['results']) {
        if (movie['original_language'] == 'en' ||
            movie['original_language'] == 'uk') {
          if (!movies.any((element) => element.id == movie['id'])) {
            fetchedMovies.add(Movie(
              id: movie['id'],
              title: movie['title'],
              poster: movie['poster_path'],
            ));
          }
        }
      }

      setState(() {
        movies.addAll(fetchedMovies);
        isLoading = false;
        pageNumber++;
      });
    } else {
      throw Exception('Failed to load movies');
    }
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
            icon: Icon(
              Icons.exit_to_app,
              color: const Color(0xFFDEDEDE),
            ),
            onPressed: () {
              _handleSignOut(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              height: 35.0,
              decoration: BoxDecoration(
                color: const Color(0xFF3C8399),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Container(
                      width: 5.0,
                      color: const Color(0xFF62A4AD),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Цікаві фільми',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 70.0,
            left: 20.0,
            right: 20.0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 35.0,
                  mainAxisSpacing: 35.0,
                ),
                itemCount: movies.length + 1,
                itemBuilder: (context, index) {
                  if (index < movies.length) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movieId: movies[index].id),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'movie_${movie.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[900],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
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
                                  style: TextStyle(
                                    color: const Color(0xFFDEDEDE),
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
                    );
                  } else if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
        ],
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
