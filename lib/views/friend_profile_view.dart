import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/user_profile_view.dart';

class FriendProfileView extends StatelessWidget {
  final String friendId;
  const FriendProfileView({Key? key, required this.friendId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(friendId).snapshots(),
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
                  Navigator.pushReplacement(
                    context,
                    CustomPageRoute(
                      builder: (context) => const UserProfile(),
                    ),
                  );
                },
              ),
            ),
            body: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(userData['profile_image'] ?? ''),
                          radius: 75,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: userData['nickname']));
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Нікнейм скопійовано: ${userData['nickname']}'),
                                ));
                              },
                              child: Text(
                                _truncateNickname(userData['nickname'] ?? '', 12),
                                style: const TextStyle(
                                  color: Color(0xFFDEDEDE),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 15),
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
                                itemCount: userData['friends'].length,
                                itemBuilder: (BuildContext context, index) {
                                  String friendId = userData['friends'][index];
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('Users').doc(friendId).get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      if (!snapshot.hasData || snapshot.data == null) {
                                        return const SizedBox();
                                      }
                                      var friendData = snapshot.data!.data() as Map<String, dynamic>;
                                      return Container(
                                        alignment: Alignment.center,
                                        width: 120,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                            const Padding(
                                                padding: EdgeInsets.only(top: 5)),
                                            Text(
                                              _truncateNickname(friendData['nickname'] ?? '', 9),
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
                      style: TextStyle(color: Color(0xFFDEDEDE), fontSize: 20),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.remove_red_eye, color: Color(0xFFDEDEDE)),
                          title: const Text('Переглянуті', style: TextStyle(color: Color(0xFFDEDEDE))),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFDEDEDE), size: 18),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.playlist_add, color: Color(0xFFDEDEDE)),
                          title: const Text('Заплановані', style: TextStyle(color: Color(0xFFDEDEDE))),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFDEDEDE), size: 18),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Color(0xFFDEDEDE)),
                          title: const Text('Покинуті', style: TextStyle(color: Color(0xFFDEDEDE))),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFDEDEDE), size: 18),
                          onTap: () {},
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Преміум',
                          style: TextStyle(color: Color(0xFFDEDEDE), fontSize: 20),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        ListTile(
                          leading: const Icon(Icons.star, color: Color(0xFFDEDEDE)),
                          title: const Text('Оформити преміум-підписку', style: TextStyle(color: Color(0xFFDEDEDE))),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFDEDEDE), size: 18),
                          onTap: () {},
                        )
                      ],
                    ),
                  ],
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
}
