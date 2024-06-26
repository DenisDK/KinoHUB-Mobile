import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kinohub/routes/routes.dart';
import 'package:image/image.dart' as img;

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
                    fontSize: 18,
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
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: _pickImage,
                    child: const Text(
                      'Фото профілю',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
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
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: _registerUser,
                    child: const Text(
                      'Реєстрація',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
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
        radius: 70,
        backgroundColor: Colors.grey[800],
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Image.file(
                  _image!,
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(
                Icons.person,
                size: 70,
                color: Colors.white,
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bool isGif = pickedFile.path.toLowerCase().endsWith('.gif');
      if (isGif) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Неможливо використовувати анімовані аватарки без преміума.'),
          ),
        );
        return;
      }

      final compressedImage = await _compressImage(File(pickedFile.path));
      setState(() {
        _image = compressedImage;
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final image = img.decodeImage(file.readAsBytesSync());
    if (image != null) {
      final compressedImage = img.encodeJpg(image, quality: 30);
      final compressedImageFile = File(file.path)
        ..writeAsBytesSync(compressedImage);
      return compressedImageFile;
    } else {
      return file;
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

    String imageUrl = _image != null
        ? await _uploadImage()
        : 'https://i.pinimg.com/564x/cc/5c/08/cc5c088add6d06315242444d78a8498d.jpg';

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

    await saveUserDataToFirebase(nickname, imageUrl, isAdmin: false);

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
      {bool isPremium = false, bool isAdmin = false}) async {
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

    batch.set(userRef, {
      'nickname': nickname,
      'profile_image': imageUrl,
      'isPremium': isPremium,
      'isAdmin': isAdmin,
      'friends': [],
    });

    await batch.commit();
  }
}
