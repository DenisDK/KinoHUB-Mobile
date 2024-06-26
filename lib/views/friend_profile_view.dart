import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/abandoned_list_view.dart';
import 'package:kinohub/views/planned_list_view.dart';
import 'package:kinohub/views/premium_view.dart';
import 'package:kinohub/views/viewed_list_view.dart';

class FriendProfileView extends StatelessWidget {
  final String friendId;
  const FriendProfileView({Key? key, required this.friendId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userData;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(friendId)
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
            appBar: AppBar(
              title: Text(
                'Профіль: ${userData['nickname']}',
                style: const TextStyle(
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
                            radius: 65,
                          ),
                          const SizedBox(width: 40),
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
                                        fontSize: 20,
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
                            ],
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(top: 30)),
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
                                          return CircularProgressIndicator();
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
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  padding: MaterialStateProperty
                                                      .all<EdgeInsetsGeometry>(
                                                          EdgeInsets.zero),
                                                  minimumSize:
                                                      MaterialStateProperty.all<
                                                          Size>(Size.zero),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    CustomPageRoute(
                                                      builder: (context) =>
                                                          FriendProfileView(
                                                              friendId:
                                                                  friendId),
                                                    ),
                                                  );
                                                },
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                    friendData[
                                                            'profile_image'] ??
                                                        '',
                                                  ),
                                                  radius: 30,
                                                ),
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
                                      ViewedMovies(userId: friendId),
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
                                      PlannedMovies(userId: friendId),
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
                                      AbandonedMovies(userId: friendId),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: giftPremium(context, userData)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget giftPremium(BuildContext context, var userData) {
    if (!userData['isPremium']) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            CustomPageRoute(
              builder: (context) => PremiumView(userId: friendId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 50),
          backgroundColor: const Color(0xFF242729),
          foregroundColor: const Color(0xFFDEDEDE),
        ),
        child: const Text(
          'Порадувати преміум 🎁',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      );
    } else {
      return const Padding(padding: EdgeInsets.only(top: 5));
    }
  }
}
