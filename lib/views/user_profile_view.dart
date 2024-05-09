import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/settings_view.dart';

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
                          radius: 65,
                        ),
                        const SizedBox(width: 35),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userData['nickname'] ?? '',
                              style: const TextStyle(
                                  color: Color(0xFFDEDEDE),
                                  fontSize: 27,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
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
                                backgroundColor:
                                    const Color(0xFF242729), // колір кнопки
                                foregroundColor:
                                    const Color(0xFFDEDEDE), // колір тексту
                              ),
                              child: const Text('Змінити профіль'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(top: 30)),
                    const Text(
                      'Друзі',
                      style: TextStyle(color: Color(0xFFDEDEDE), fontSize: 20),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 10)),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTq6ZeoZMtqemS0k5w0ylnONNLWu1426xbXpeUJTbEI4w&s'),
                                    radius: 30,
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 5)),
                                  Text(
                                    'AlexStavok',
                                    style: TextStyle(
                                        color: Color(0xFFDEDEDE), fontSize: 13),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
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
}
