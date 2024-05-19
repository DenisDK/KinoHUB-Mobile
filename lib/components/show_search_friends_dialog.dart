import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

void showSearchFriendsDialog(BuildContext context,
    TextEditingController nicknameController, Map<String, dynamic> userData) {
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> filteredDocuments = [];

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
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    List<DocumentSnapshot> documents = snapshot.data!.docs;

                    return Column(
                      children: [
                        TextField(
                          controller: nicknameController,
                          cursorColor: const Color(0xFFFF5200),
                          decoration: InputDecoration(
                            labelText: 'Нікнейм друга',
                            labelStyle:
                                const TextStyle(color: Color(0xFFDEDEDE)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[700],
                            suffixIcon: IconButton(
                              onPressed: () {
                                nicknameController.clear();
                                setState(() {
                                  filteredDocuments.clear();
                                });
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
                                  if (nickname.contains(value.toLowerCase()) &&
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
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ListTile(
                                  tileColor: Colors.grey[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      filteredDocuments[index]
                                          .get('profile_image'),
                                    ),
                                  ),
                                  title: Text(
                                    filteredDocuments[index].get('nickname'),
                                    style: const TextStyle(
                                        color: Color(0xFFDEDEDE)),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.person_add),
                                    color: const Color(0xFFDEDEDE),
                                    onPressed: () async {
                                      if (userData['isPremium']) {
                                        if (!userData['friends'].contains(
                                            filteredDocuments[index].id)) {
                                          await FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(currentUser!.uid)
                                              .update({
                                            'friends': FieldValue.arrayUnion(
                                                [filteredDocuments[index].id])
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Користувач ${filteredDocuments[index].get('nickname')} додано до списку друзів')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Користувач ${filteredDocuments[index].get('nickname')} вже є в списку друзів')),
                                          );
                                        }
                                      } else {
                                        if (userData['friends'].length >= 5) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Ви не можете додати більше 5 друзів без преміум підписки :(')),
                                          );
                                        } else {
                                          if (!userData['friends'].contains(
                                              filteredDocuments[index].id)) {
                                            await FirebaseFirestore.instance
                                                .collection('Users')
                                                .doc(currentUser!.uid)
                                                .update({
                                              'friends': FieldValue.arrayUnion(
                                                  [filteredDocuments[index].id])
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Користувач ${filteredDocuments[index].get('nickname')} додано до списку друзів')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Користувач ${filteredDocuments[index].get('nickname')} вже є в списку друзів')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
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
    nicknameController.clear();
  });
}
