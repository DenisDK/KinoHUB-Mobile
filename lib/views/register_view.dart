import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kinohub/routes/routes.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({Key? key}) : super(key: key);

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final TextEditingController _nicknameController = TextEditingController();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Color(0xFF262626),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Реєстрація нового користувача',
                  style: TextStyle(
                    color: Color(0xFFDEDEDE),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAvatar(),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.53,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF242729)),
                      foregroundColor: MaterialStateProperty.all(
                        const Color(0xFFDEDEDE),
                      ),
                    ),
                    onPressed: _pickImage,
                    child: const Text('Виберіть фото профілю'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextField(
                    controller: _nicknameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFDEDEDE)),
                    cursorColor: const Color(0xFFFF5200),
                    decoration: InputDecoration(
                      labelText: 'Введіть свій нікнейм',
                      labelStyle: const TextStyle(color: Color(0xFFDEDEDE)),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.53,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF242729)),
                      foregroundColor: MaterialStateProperty.all(
                        const Color(0xFFDEDEDE),
                      ),
                    ),
                    onPressed: _registerUser,
                    child: const Text('Реєстрація'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[800],
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.file(
                  _image!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerUser() async {
    String nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нікнейм не може бути порожнім'),
        ),
      );
      return;
    }

    String imageUrl = _image != null ? await _uploadImage() : '';

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('nickname', isEqualTo: nickname)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Користувач з таким нікнеймом вже існує. Виберіть інший нікнейм.'),
        ),
      );
      return;
    }

    await saveUserDataToFirebase(nickname, imageUrl);

    Navigator.of(context).pushNamedAndRemoveUntil(
      mainMenuRoute,
      (route) => false,
    );
  }

  Future<String> _uploadImage() async {
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_images');

    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final TaskSnapshot uploadTask =
        await storageRef.child(fileName).putFile(_image!);
    final imageUrl = await uploadTask.ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> saveUserDataToFirebase(String nickname, String imageUrl,
      {bool isPremium = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    final batch = FirebaseFirestore.instance.batch();
    final userRef =
        FirebaseFirestore.instance.collection('Users').doc(user?.uid);

    final collections = ['WatchedMovies', 'PlannedMovies', 'AbandonedMovies'];
    collections.forEach((collection) {
      batch.set(userRef.collection(collection).doc(), {
        'filmID': 0,
      });
    });

    batch.set(userRef.collection('Friends').doc(), {
      'friend_nickname': '',
    });

    await batch.commit();

    await userRef.set({
      'nickname': nickname,
      'profile_image': imageUrl,
      'isPremium': isPremium,
    });
  }
}
