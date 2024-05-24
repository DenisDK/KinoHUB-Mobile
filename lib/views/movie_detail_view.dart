import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kinohub/API%20service/movie_class.dart';
import 'package:kinohub/API%20service/movie_methods.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';
import 'package:kinohub/components/drop_down_for_film.dart';
import 'package:kinohub/firestore_database/add_films_to_list.dart';

import '../components/alert_dialog_custom.dart';
import 'friend_profile_view.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  String buttonName = 'Додати до списку';
  bool liked = false;
  bool disliked = false;
  TextEditingController commentController = TextEditingController();
  var user = FirebaseAuth.instance.currentUser;

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
                                  'Рейтинг IMDB: ${movie.rating}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14.84,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            FutureBuilder(
                              future: fetchUserRating(widget.movieId),
                              builder: (context,
                                  AsyncSnapshot<double> ratingSnapshot) {
                                if (ratingSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (ratingSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Помилка: ${ratingSnapshot.error}'));
                                } else {
                                  double userRating = ratingSnapshot.data!;
                                  return Container(
                                    padding: const EdgeInsets.all(8.0),
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 160, 59),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Рейтинг KinoHUB: ${userRating.toInt()}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14.8,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: const Color.fromARGB(255, 50, 50, 50),
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
                            GestureDetector(
                              child: Material(
                                color: Colors.transparent,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 50, 50, 50),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      String trailerUrl =
                                          await fetchMovieTrailer(
                                              widget.movieId);
                                      launchURL(trailerUrl, context);
                                    },
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height: 50.0,
                                      child: const Center(
                                        child: Text(
                                          'Трейлер',
                                          style: TextStyle(
                                            color: Color(0xFFDEDEDE),
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.19,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: liked
                                        ? const Color.fromARGB(255, 54, 109, 63)
                                        : const Color.fromARGB(255, 50, 50, 50),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      icon: const Icon(Icons.thumb_up,
                                          color: Color(0xFFDEDEDE)),
                                      onPressed: () async {
                                        setState(() {
                                          liked = !liked;
                                          if (liked) {
                                            disliked = false;
                                          }
                                          handleLike(widget.movieId);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.19,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: disliked
                                        ? const Color.fromARGB(255, 129, 56, 56)
                                        : const Color.fromARGB(255, 50, 50, 50),
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      icon: const Icon(Icons.thumb_down,
                                          color: Color(0xFFDEDEDE)),
                                      onPressed: () async {
                                        setState(() {
                                          disliked = !disliked;
                                          if (disliked) {
                                            liked = false;
                                          }
                                          handleDislike(widget.movieId);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 50, 50, 50),
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
                      color: const Color.fromARGB(255, 50, 50, 50),
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
                  // Місце для написання нового коментаря
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        'Напишіть ваш відгук:',
                        style: TextStyle(
                            fontSize: 19.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDEDEDE)),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                        ),
                        child: TextField(
                          controller: commentController,
                          cursorColor: const Color(0xFFFF5200),
                          decoration: InputDecoration(
                            labelText: 'Пишіть тут...',
                            labelStyle:
                                const TextStyle(color: Color(0xFFDEDEDE)),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 50, 50, 50),
                          ),
                          style: const TextStyle(
                              color: Color(0xFFDEDEDE), fontSize: 16.0),
                          minLines: 1,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 50, 50, 50),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: InkWell(
                              onTap: () async {
                                addComment();
                              },
                              borderRadius: BorderRadius.circular(10.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 50.0,
                                child: const Center(
                                  child: Text(
                                    'Додати відгук',
                                    style: TextStyle(
                                      color: Color(0xFFDEDEDE),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Коментарі
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Comments')
                        .doc(widget.movieId.toString())
                        .collection('comment')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Помилка: ${snapshot.error}'));
                      }
                      final comments = snapshot.data?.docs ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Text(
                              'Ішні відгуки:',
                              style: TextStyle(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDEDEDE)),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index].data()
                                  as Map<String, dynamic>;
                              return FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(comment['userID'])
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot>
                                        userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                  }
                                  if (userSnapshot.hasError) {
                                    return Text(
                                        'Помилка при завантаженні користувача: ${userSnapshot.error}');
                                  }
                                  final userData = userSnapshot.data?.data()
                                      as Map<String, dynamic>;
                                  final nickname = userData['nickname'] ??
                                      'Анонімний користувач';
                                  final bool isPremium =
                                      userData['isPremium'] ?? false;

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    padding: const EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 50, 50, 50),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) {
                                              return FriendProfileView(
                                                  friendId: comment['userID']);
                                            },
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(1.0, 0.0);
                                              const end = Offset.zero;
                                              const curve = Curves.ease;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));

                                              return SlideTransition(
                                                position:
                                                    animation.drive(tween),
                                                child: child,
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      leading: CircleAvatar(
                                        radius: 27,
                                        backgroundImage: NetworkImage(
                                            userData['profile_image'] ?? ''),
                                      ),
                                      title: Row(
                                        children: [
                                          if (isPremium)
                                            Row(
                                              children: [
                                                Text(
                                                  '${nickname ?? 'Анонімний користувач'}',
                                                  style: const TextStyle(
                                                      color: Color(0xFFDEDEDE),
                                                      fontSize: 17.7,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                const SizedBox(width: 3),
                                                const Icon(
                                                  Icons.workspace_premium,
                                                  color: Color.fromARGB(
                                                      255, 233, 156, 88),
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          if (!isPremium)
                                            Text(
                                              '${nickname ?? 'Анонімний користувач'}',
                                              style: const TextStyle(
                                                  color: Color(0xFFDEDEDE),
                                                  fontSize: 17.7,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        comment['com'] ?? '',
                                        style: const TextStyle(
                                          color: Color(0xFFDEDEDE),
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing: user?.uid == comment['userID']
                                          ? IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Color.fromARGB(
                                                      255, 242, 111, 50)),
                                              onPressed: () async {
                                                bool? result =
                                                    await CustomDialogAlert
                                                        .showConfirmationDialog(
                                                  context,
                                                  'Видалення відгуку',
                                                  'Ви впевнені, що хочете видалити відгук?',
                                                );
                                                if (result != null && result) {
                                                  deleteComment(comments[index]
                                                      .reference);
                                                } else {}
                                              },
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
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
    checkUserChoice(widget.movieId);
  }

  Future<void> handleLike(int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final ratingRef = FirebaseFirestore.instance
          .collection('Rating')
          .doc(movieId.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(ratingRef);
        if (!snapshot.exists) {
          transaction.set(ratingRef, {
            'filmID': movieId,
            'likes': [userId],
            'dislikes': [],
          });
        } else {
          List<dynamic> likes = snapshot.get('likes');
          List<dynamic> dislikes = snapshot.get('dislikes');

          if (likes.contains(userId)) {
            likes.remove(userId);
          } else {
            likes.add(userId);
            if (dislikes.contains(userId)) {
              dislikes.remove(userId);
            }
          }

          transaction.update(ratingRef, {
            'likes': likes,
            'dislikes': dislikes,
          });
        }
      });
    }
  }

  Future<void> handleDislike(int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final ratingRef = FirebaseFirestore.instance
          .collection('Rating')
          .doc(movieId.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(ratingRef);
        if (!snapshot.exists) {
          transaction.set(ratingRef, {
            'filmID': movieId,
            'likes': [],
            'dislikes': [userId],
          });
        } else {
          List<dynamic> likes = snapshot.get('likes');
          List<dynamic> dislikes = snapshot.get('dislikes');

          if (dislikes.contains(userId)) {
            dislikes.remove(userId);
          } else {
            dislikes.add(userId);
            if (likes.contains(userId)) {
              likes.remove(userId);
            }
          }

          transaction.update(ratingRef, {
            'likes': likes,
            'dislikes': dislikes,
          });
        }
      });
    }
  }

  Future<double> fetchUserRating(int movieId) async {
    final ratingRef =
        FirebaseFirestore.instance.collection('Rating').doc(movieId.toString());
    final snapshot = await ratingRef.get();

    if (snapshot.exists) {
      List<dynamic> likes = snapshot.get('likes');
      List<dynamic> dislikes = snapshot.get('dislikes');
      int totalVotes = likes.length + dislikes.length;
      if (totalVotes == 0) {
        return 0.0;
      } else {
        double likePercentage = (likes.length / totalVotes) * 10;
        return likePercentage;
      }
    } else {
      return 0.0;
    }
  }

  Future<void> checkUserChoice(int movieId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final ratingRef = FirebaseFirestore.instance
          .collection('Rating')
          .doc(movieId.toString());

      final snapshot = await ratingRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final likes = List<String>.from(data['likes']);
        final dislikes = List<String>.from(data['dislikes']);

        if (likes.contains(userId)) {
          setState(() {
            liked = true;
            disliked = false;
          });
        } else if (dislikes.contains(userId)) {
          setState(() {
            liked = false;
            disliked = true;
          });
        }
      }
    }
  }

  void addComment() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userID = user.uid;
      final commentText = commentController.text.trim();
      if (commentText.isNotEmpty) {
        FirebaseFirestore.instance
            .collection('Comments')
            .doc(widget.movieId.toString())
            .collection('comment')
            .add({
          'com': commentText,
          'userID': userID,
          'timestamp': DateTime.now(),
        }).then((value) {
          commentController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Коментар додано успішно!')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Помилка: $error')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Будь ласка, введіть коментар!')),
        );
      }
    }
  }

  void deleteComment(DocumentReference commentRef) {
    commentRef.delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Коментар видалено!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка під час видалення коментаря: $error')),
      );
    });
  }
}
