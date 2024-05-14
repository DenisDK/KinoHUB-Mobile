import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/abandoned_list_view.dart';
import 'package:kinohub/views/friend_profile_view.dart';
import 'package:kinohub/views/planned_list_view.dart';
import 'package:kinohub/views/premium_view.dart';
import 'package:kinohub/views/settings_view.dart';
import 'package:kinohub/views/viewed_list_view.dart';

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
                                Clipboard.setData(
                                    ClipboardData(text: userData['nickname']));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Нікнейм скопійовано: ${userData['nickname']}'),
                                ));
                              },
                              child: Text(
                                _truncateNickname(
                                    userData['nickname'] ?? '', 12),
                                style: const TextStyle(
                                  color: Color(0xFFDEDEDE),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  CustomPageRoute(
                                    builder: (context) => const SettingsView(),
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
                                  String friendId = userData['friends'][index];
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(friendId)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
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
                                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                                                    minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                                                  ),
                                                  onPressed: (){
                                                    Navigator.push(
                                                      context,
                                                      CustomPageRoute(
                                                        builder: (context) => FriendProfileView(friendId: friendId),
                                                      ),
                                                    );
                                                  }, 
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                      friendData['profile_image'] ?? '',
                                                    ),
                                                    radius: 30,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: -15,
                                                  right: -15,
                                                  child: IconButton(
                                                    icon: Icon(Icons.delete),
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                "Видалити друга?"),
                                                            content: const Text(
                                                                "Ви впевнені, що хочете видалити цього друга?"),
                                                            actions: [
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  "Ні",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xFFFF5200),
                                                                  ),
                                                                ),
                                                                onPressed: () {
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
                                                                    color: Color(
                                                                        0xFFFF5200),
                                                                  ),
                                                                ),
                                                                onPressed: () {
                                                                  String
                                                                    friendId =  userData['friends'][index];
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection('Users')
                                                                      .doc(user!.uid)
                                                                      .update({
                                                                    'friends':
                                                                      FieldValue
                                                                      .arrayRemove([friendId])
                                                                  });
                                                                  Navigator.of(context)
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
                                                  friendData['nickname'] ?? '',
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
                              _showSearchFriendsDialog(context);
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
                      style: TextStyle(color: Color(0xFFDEDEDE), fontSize: 20),
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
                                builder: (context) => ViewedMovies(userId: user.uid),
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
                                builder: (context) => PlannedMovies(userId: user.uid),
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
                                builder: (context) => AbandonedMovies(userId: user.uid),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Преміум',
                          style:
                              TextStyle(color: Color(0xFFDEDEDE), fontSize: 20),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        ListTile(
                          leading:
                              const Icon(Icons.star, color: Color(0xFFDEDEDE)),
                          title: const Text('Оформити преміум-підписку',
                              style: TextStyle(color: Color(0xFFDEDEDE))),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Color(0xFFDEDEDE), size: 18),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              CustomPageRoute(
                                builder: (context) => PremiumView(),
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

  void _showSearchFriendsDialog(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[800],
              title: const Text(
                'Знайти друга',
                style: TextStyle(color: Color(0xFFDEDEDE), fontSize: 20),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return CircularProgressIndicator();
                      }
                      List<DocumentSnapshot> documents = snapshot.data!.docs;

                      return Column(
                        children: [
                          TextField(
                            controller: _nicknameController,
                            cursorColor: const Color(0xFFFF5200),
                            decoration: InputDecoration(
                              labelText: 'Нікнейм друга',
                              labelStyle: const TextStyle(
                                color: Color(0xFFDEDEDE),
                              ),
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
                              fillColor: Colors.grey[700],
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _nicknameController.clear();
                                },
                                icon: const Icon(Icons.clear,
                                    color: Color(0xFFDEDEDE)),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                filteredDocuments.clear();
                                if (value.isNotEmpty) {
                                  for (var doc in documents) {
                                    String nickname = doc
                                        .get('nickname')
                                        .toString()
                                        .toLowerCase();
                                    if (nickname
                                            .contains(value.toLowerCase()) &&
                                        doc.id != currentUser!.uid) {
                                      filteredDocuments.add(doc);
                                    }
                                  }
                                }
                              });
                            },
                            style: const TextStyle(color: Color(0xFFDEDEDE)),
                          ),
                          SizedBox(
                            height: 200,
                            width: 300,
                            child: ListView.builder(
                              itemCount: filteredDocuments.length,
                              itemBuilder: (BuildContext context, index) {
                                return Dismissible(
                                    key: Key(filteredDocuments[index].id),
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: ListTile(
                                          tileColor: Colors.grey[700],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                filteredDocuments[index]
                                                    .get('profile_image')),
                                          ),
                                          title: Text(
                                            filteredDocuments[index]
                                                .get('nickname'),
                                            style: const TextStyle(
                                                color: Color(0xFFDEDEDE)),
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.person_add),
                                            color: const Color(0xFFDEDEDE),
                                            onPressed: () {
                                              if (userData['isPremium']) {
                                                if (!userData['friends']
                                                    .contains(
                                                        filteredDocuments[index]
                                                            .id)) {
                                                  FirebaseFirestore.instance
                                                      .collection('Users')
                                                      .doc(currentUser!.uid)
                                                      .update({
                                                    'friends':
                                                        FieldValue.arrayUnion([
                                                      filteredDocuments[index]
                                                          .id
                                                    ])
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Користувач ${filteredDocuments[index].get('nickname')} додано до списку друзів'),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Користувач ${filteredDocuments[index].get('nickname')} вже є в списку друзів'),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                if (userData['friends']
                                                        .length >=
                                                    5) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Користувач ${filteredDocuments[index].get('nickname')} ви не можете додати більше 5 друзів без преміум підписки :('),
                                                    ),
                                                  );
                                                } else {
                                                  if (!userData['friends']
                                                      .contains(
                                                          filteredDocuments[
                                                                  index]
                                                              .id)) {
                                                    FirebaseFirestore.instance
                                                        .collection('Users')
                                                        .doc(currentUser!.uid)
                                                        .update({
                                                      'friends': FieldValue
                                                          .arrayUnion([
                                                        filteredDocuments[index]
                                                            .id
                                                      ])
                                                    });
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Користувач ${filteredDocuments[index].get('nickname')} додано до списку друзів'),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Користувач ${filteredDocuments[index].get('nickname')} вже є в списку друзів'),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        )));
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      filteredDocuments.clear();
      _nicknameController.clear();
    });
  }
}
