import 'package:flutter/material.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/firestore_database/methods_for_movie_list.dart';
import 'package:kinohub/views/movie_detail_view.dart';

class PlannedMovies extends StatefulWidget {
  final String userId;
  const PlannedMovies({Key? key, required this.userId}) : super(key: key);

  @override
  State<PlannedMovies> createState() => _PlannedMoviesState();
}

class _PlannedMoviesState extends State<PlannedMovies> {
  late Future<List<Map<String, dynamic>>> movies;

  @override
  void initState() {
    super.initState();
    movies = plannedMovies(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Заплановані фільми',
          style: TextStyle(
            color: Color(0xFFD3D3D3),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFFD3D3D3),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> moviesList = snapshot.data ?? [];
            return GridView.builder(
              padding: const EdgeInsets.all(20.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 35.0,
                mainAxisSpacing: 35.0,
                childAspectRatio: 0.7,
              ),
              itemCount: moviesList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        builder: (context) =>
                            MovieDetailScreen(movieId: moviesList[index]['id']),
                      ),
                    );
                  },
                  child: Container(
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10.0),
                            ),
                            child: Image.network(
                              moviesList[index]['poster'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            moviesList[index]['title'],
                            style: const TextStyle(
                              color: Color(0xFFDEDEDE),
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
