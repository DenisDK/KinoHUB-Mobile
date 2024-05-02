import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kinohub/API%20service/movie_class.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kinohub/components/bottom_appbar_custom.dart';
import '../components/drop_down_for_film.dart';

class MovieDetailScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchMovieDetails(movieId),
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
                        // Постер фільму
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            movie.poster,
                            width: 190,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Рейтинг фільму
                            Container(
                              padding: EdgeInsets.all(8.0),
                              width: 160.0,
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
                              width: 165.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Color(0xFF242729),
                              ),
                              child: Center(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  iconSize: 0.0,
                                  elevation: 16,
                                  style: const TextStyle(
                                      color: Color(0xFFDEDEDE), fontSize: 16.0),
                                  underline: Container(height: 0),
                                  onChanged: (String? newValue) {
                                    // сюди нічого додавати не треба)
                                  },
                                  items: CustomPopupMenu.choices
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: CustomPopupMenuItem(
                                        text: value,
                                        onTap: () {
                                          // Обробка події при виборі елемента
                                          switch (value) {
                                            case CustomPopupMenu.viewed:
                                              // сюда код чи метод для додавання фільмів в Переглянуті
                                              break;
                                            case CustomPopupMenu.planned:
                                              // сюда код чи метод для додавання фільмів в  Заплановані
                                              break;
                                            case CustomPopupMenu.abandoned:
                                              // сюда код чи метод для додавання фільмів в покинуті
                                              break;
                                            default:
                                          }
                                        },
                                      ),
                                    );
                                  }).toList(),
                                  hint: const Center(
                                    child: Text(
                                      'Додати до списку',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFFDEDEDE),
                                          fontSize: 16.0),
                                    ),
                                  ),
                                  dropdownColor:
                                      Color.fromARGB(255, 48, 48, 48),
                                  borderRadius: BorderRadius.circular(10.0),
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
                          margin: EdgeInsets.symmetric(vertical: 8.0),
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

  Future<DetailedMovie> fetchMovieDetails(int movieId) async {
    String apiKey = dotenv.env['API_KEY'] ?? '';
    const baseUrl = 'https://api.themoviedb.org/3/movie';
    const defaultLanguage = 'uk-UA';
    const fallbackLanguage = 'en-US'; // Англійська мова як резерв

    try {
      // Спробуємо завантажити дані про фільм на українській мові
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

        // Отримання вікового обмеження
        String certification = '';
        final releaseDates = jsonData['release_dates']['results'];
        for (var result in releaseDates) {
          if (result['iso_3166_1'] == 'US') {
            certification = result['release_dates'][0]['certification'];
            break;
          }
        }

        // Отримання країн виробництва
        List<String> productionCountries = [];
        final countries = jsonData['production_countries'];
        for (var country in countries) {
          productionCountries.add(country['name']);
        }

        // Отримання студії
        String productionStudio = '';
        final studios = jsonData['production_companies'];
        if (studios.isNotEmpty) {
          productionStudio = studios[0]['name'];
        }

        // Перевірка доступності опису на українській мові
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

  // Функція для перевірки доступності тексту на заданій мові
  Future<String> checkLanguageAvailability(
      String text,
      int movieId,
      String language,
      String fallbackLanguage,
      String apiKey,
      String baseUrl) async {
    if (text.isEmpty) {
      final responseEn = await http.get(
        Uri.parse(
            '$baseUrl/$movieId?api_key=$apiKey&language=$fallbackLanguage'),
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
}
