import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kinohub/API%20service/movie_class.dart';
import 'package:kinohub/API%20service/movie_methods.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';
import 'package:kinohub/components/drop_down_for_film.dart';
import 'package:kinohub/firestore_database/add_films_to_list.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  String buttonName = 'Додати до списку';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchMovieDetails(widget.movieId),
        builder: (context, AsyncSnapshot<DetailedMovie> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Помилка: ${snapshot.error}'));
          } else {
            DetailedMovie movie = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDEDEDE),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (movie.poster != 'N/A')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            movie.poster,
                            width: MediaQuery.of(context).size.width * 0.5 -
                                20, // Змінили ширину постера
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 160, 59),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Рейтинг: ${movie.rating}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: const Color(0xFF242729),
                              ),
                              child: Center(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  iconSize: 0.0,
                                  elevation: 16,
                                  style: const TextStyle(
                                    color: Color(0xFFDEDEDE),
                                    fontSize: 16.0,
                                  ),
                                  underline: Container(height: 0),
                                  onChanged: (String? newValue) {},
                                  items: CustomPopupMenu.choices
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: CustomPopupMenuItem(
                                        text: value,
                                        onTap: () async {
                                          switch (value) {
                                            case CustomPopupMenu.viewed:
                                              bool isAddedToWatched =
                                                  await addToWatchedList(
                                                      context, movie.id);
                                              if (isAddedToWatched) {
                                                updateButtonName('Переглянуто');
                                              }
                                              break;
                                            case CustomPopupMenu.planned:
                                              bool isAddedToPlanned =
                                                  await addToPlannedList(
                                                      context, movie.id);
                                              if (isAddedToPlanned) {
                                                updateButtonName('Заплановано');
                                              }
                                              break;
                                            case CustomPopupMenu.abandoned:
                                              bool isAddedToAbandoned =
                                                  await addToAbandonedList(
                                                      context, movie.id);
                                              if (isAddedToAbandoned) {
                                                updateButtonName('Покинуто');
                                              }
                                              break;
                                            case CustomPopupMenu.delete:
                                              await removeFromAllList(
                                                  context, movie.id);
                                              updateButtonName(
                                                  'Додати до списку');
                                              break;
                                            default:
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                  hint: Center(
                                    child: Text(
                                      buttonName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFDEDEDE),
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  dropdownColor:
                                      const Color.fromARGB(255, 48, 48, 48),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: const Color(0xFF242729),
                              ),
                              child: Center(
                                child: TextButton(
                                  onPressed: () async {
                                    String trailerUrl =
                                        await fetchMovieTrailer(widget.movieId);
                                    launchURL(trailerUrl, context);
                                  },
                                  child: const Text(
                                    'Трейлер',
                                    style: TextStyle(
                                      color: Color(0xFFDEDEDE),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242729),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Інформація про фільм:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 2,
                          color: Colors.grey,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Жанри: ${movie.genres.isNotEmpty ? movie.genres.join(", ") : "Інформація не знайдена"}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Рік випуску: ${movie.releaseYear}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Режисер: ${movie.director.isNotEmpty ? movie.director : "Інформація не знайдена"}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Вікове обмеження: ${movie.certification.isNotEmpty ? movie.certification : "Інформація не знайдена"}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Країни виробництва: ${movie.productionCountries.isNotEmpty ? movie.productionCountries.join(", ") : "Інформація не знайдена"}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Студія: ${movie.productionStudio.isNotEmpty ? movie.productionStudio : "Інформація не знайдена"}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242729),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Опис фільму:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 2,
                          color: Colors.grey,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          movie.overview.isNotEmpty
                              ? movie.overview
                              : 'Інформація не знайдена',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFFDEDEDE),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: MainBottomNavigationBar(
        selectedIndex: 1,
        onTap: (index) {},
      ),
    );
  }

  Future<void> updateButtonName(String value) async {
    setState(() {
      buttonName = value;
    });
  }

  Future<void> checkIfMovieAdded(BuildContext context, int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);

      try {
        final lists = ['WatchedMovies', 'PlannedMovies', 'AbandonedMovies'];

        for (var listName in lists) {
          final snapshot = await userRef
              .collection(listName)
              .where('filmID', isEqualTo: movieId)
              .get();

          if (snapshot.docs.isNotEmpty) {
            switch (listName) {
              case 'WatchedMovies':
                updateButtonName('Переглянуто');
                break;
              case 'PlannedMovies':
                updateButtonName('Заплановано');
                break;
              case 'AbandonedMovies':
                updateButtonName('Покинуто');
                break;
            }
            return;
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка при перевірці списків: $e'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfMovieAdded(context, widget.movieId);
  }
}
