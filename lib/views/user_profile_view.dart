import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/abandoned_list_view.dart';
import 'package:kinohub/views/friend_profile_view.dart';
import 'package:kinohub/views/planned_list_view.dart';
import 'package:kinohub/views/premium_view.dart';
import 'package:kinohub/views/settings_view.dart';
import 'package:kinohub/views/viewed_list_view.dart';

import '../components/show_search_friends_dialog.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _nicknameController = TextEditingController();
  List<DocumentSnapshot> filteredDocuments = [];
  var userData;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          userData = snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(userData['profile_image'] ?? ''),
                            radius: 75,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: userData['nickname']));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Нікнейм скопійовано: ${userData['nickname']}'),
                                  ));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _truncateNickname(
                                          userData['nickname'] ?? '', 12),
                                      style: const TextStyle(
                                        color: Color(0xFFDEDEDE),
                                        fontSize: 19.7,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (userData['isPremium'] == true)
                                      const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(
                                          Icons.workspace_premium,
                                          color:
                                              Color.fromARGB(255, 233, 156, 88),
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    CustomPageRoute(
                                      builder: (context) =>
                                          const SettingsView(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(135, 45),
                                  backgroundColor: const Color(0xFF242729),
                                  foregroundColor: const Color(0xFFDEDEDE),
                                ),
                                child: const Text('Змінити профіль'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Друзі',
                              style: TextStyle(
                                  color: Color(0xFFDEDEDE), fontSize: 20),
                            ),
                            const SizedBox(height: 15),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SizedBox(
                                height: 120,
                                width: 370,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: userData['friends'].length,
                                  itemBuilder: (BuildContext context, index) {
                                    String friendId =
                                        userData['friends'][index];
                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(friendId)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.data == null) {
                                          return const SizedBox();
                                        }
                                        var friendData = snapshot.data!.data()
                                            as Map<String, dynamic>;
                                        return Container(
                                          alignment: Alignment.center,
                                          width: 120,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      padding: MaterialStateProperty
                                                          .all<EdgeInsetsGeometry>(
                                                              EdgeInsets.zero),
                                                      minimumSize:
                                                          MaterialStateProperty
                                                              .all<Size>(
                                                                  Size.zero),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (context,
                                                              animation,
                                                              secondaryAnimation) {
                                                            return FriendProfileView(
                                                                friendId:
                                                                    friendId);
                                                          },
                                                          transitionsBuilder:
                                                              (context,
                                                                  animation,
                                                                  secondaryAnimation,
                                                                  child) {
                                                            const begin =
                                                                Offset(
                                                                    1.0, 0.0);
                                                            const end =
                                                                Offset.zero;
                                                            const curve =
                                                                Curves.ease;

                                                            var tween = Tween(
                                                                    begin:
                                                                        begin,
                                                                    end: end)
                                                                .chain(CurveTween(
                                                                    curve:
                                                                        curve));

                                                            return SlideTransition(
                                                              position: animation
                                                                  .drive(tween),
                                                              child: child,
                                                            );
                                                          },
                                                          transitionDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                        ),
                                                      );
                                                    },
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                        friendData[
                                                                'profile_image'] ??
                                                            '',
                                                      ),
                                                      radius: 30,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: -15,
                                                    right: -15,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          size: 23),
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              242,
                                                              111,
                                                              50),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  Colors.grey[
                                                                      800],
                                                              title: const Text(
                                                                "Видалити друга?",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFFDEDEDE), // Задаємо колір тексту заголовка
                                                                ),
                                                              ),
                                                              content:
                                                                  const Text(
                                                                "Ви впевнені, що хочете видалити цього друга?",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFFDEDEDE), // Задаємо колір тексту контенту
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                    "Ні",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          242,
                                                                          111,
                                                                          50),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                    "Так",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          242,
                                                                          111,
                                                                          50),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    String
                                                                        friendId =
                                                                        userData['friends']
                                                                            [
                                                                            index];
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'Users')
                                                                        .doc(user
                                                                            .uid)
                                                                        .update({
                                                                      'friends':
                                                                          FieldValue
                                                                              .arrayRemove([
                                                                        friendId
                                                                      ])
                                                                    });
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 5)),
                                              Text(
                                                _truncateNickname(
                                                    friendData['nickname'] ??
                                                        '',
                                                    9),
                                                style: const TextStyle(
                                                    color: Color(0xFFDEDEDE),
                                                    fontSize: 13),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 50),
                                backgroundColor: const Color(0xFF242729),
                                foregroundColor: const Color(0xFFDEDEDE),
                              ),
                              onPressed: () {
                                showSearchFriendsDialog(
                                    context, _nicknameController, userData);
                              },
                              child: const Text('Додати нового друга'),
                            ),
                            const SizedBox(height: 7), // Доданий відступ
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Списки фільмів',
                        style:
                            TextStyle(color: Color(0xFFDEDEDE), fontSize: 20),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.remove_red_eye,
                                color: Color(0xFFDEDEDE)),
                            title: const Text('Переглянуті',
                                style: TextStyle(color: Color(0xFFDEDEDE))),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Color(0xFFDEDEDE), size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  builder: (context) =>
                                      ViewedMovies(userId: user.uid),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.playlist_add,
                                color: Color(0xFFDEDEDE)),
                            title: const Text('Заплановані',
                                style: TextStyle(color: Color(0xFFDEDEDE))),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Color(0xFFDEDEDE), size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  builder: (context) =>
                                      PlannedMovies(userId: user.uid),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete,
                                color: Color(0xFFDEDEDE)),
                            title: const Text('Покинуті',
                                style: TextStyle(color: Color(0xFFDEDEDE))),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Color(0xFFDEDEDE), size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  builder: (context) =>
                                      AbandonedMovies(userId: user.uid),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Преміум',
                            style: TextStyle(
                                color: Color(0xFFDEDEDE), fontSize: 20),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 10)),
                          ListTile(
                            leading: const Icon(Icons.star,
                                color: Color(0xFFDEDEDE)),
                            title: const Text('Оформити преміум-підписку',
                                style: TextStyle(color: Color(0xFFDEDEDE))),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Color(0xFFDEDEDE), size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  builder: (context) => PremiumView(
                                    userId: user.uid,
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: MainBottomNavigationBar(
              selectedIndex: 2,
              onTap: (index) {},
            ),
          );
        }
      },
    );
  }

  String _truncateNickname(String nickname, int maxLength) {
    if (nickname.length > maxLength) {
      return nickname.substring(0, maxLength) + '...';
    } else {
      return nickname;
    }
  }
}
