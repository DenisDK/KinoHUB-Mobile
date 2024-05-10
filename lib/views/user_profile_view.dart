import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/abandoned_list_view.dart';
import 'package:kinohub/views/planned_list_view.dart';

import 'package:kinohub/views/premium_view.dart';
import 'package:kinohub/views/settings_view.dart';
import 'package:kinohub/views/viewed_list_view.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key});

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
          var userData = snapshot.data!.data() as Map<String, dynamic>;
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
                                Navigator.push(
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
                          const SizedBox(height: 15),
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
                                itemCount: 8,
                                itemBuilder: (context, index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    width: 120,
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTq6ZeoZMtqemS0k5w0ylnONNLWu1426xbXpeUJTbEI4w&s'),
                                          radius: 30,
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 5)),
                                        Text(
                                          'AlexStavok',
                                          style: TextStyle(
                                              color: Color(0xFFDEDEDE),
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
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
                            onPressed: () {},
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
                                builder: (context) => const ViewedMovies(),
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
                                builder: (context) => const PlannedMovies(),
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
                                builder: (context) => const AbandonedMovies(),
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
                            Navigator.push(
                              context,
                              CustomPageRoute(
                                builder: (context) => const PremiumView(),
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
}
