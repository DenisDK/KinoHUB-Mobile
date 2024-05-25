import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/user_profile_view.dart';
import 'package:image/image.dart' as img;

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  User? user = FirebaseAuth.instance.currentUser;
  File? _image;
  var userData;
  bool isPremium = false;
  TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          isPremium = userData['isPremium'] ?? false;
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Змінити профіль',
                style: TextStyle(
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
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 1.2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(185, 50)),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF242729)),
                          foregroundColor: MaterialStateProperty.all(
                              const Color(0xFFDEDEDE)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: _pickImage,
                        child: const Text(
                          'Змінити фото',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nicknameController,
                        cursorColor: const Color(0xFFFF5200),
                        decoration: InputDecoration(
                          labelText: 'Новий нікнейм',
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
                          fillColor: Colors.grey[800],
                          suffixIcon: IconButton(
                            onPressed: () {
                              _nicknameController.clear();
                            },
                            icon: const Icon(Icons.clear,
                                color: Color(0xFFDEDEDE)),
                          ),
                        ),
                        style: const TextStyle(color: Color(0xFFDEDEDE)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(185, 50)),
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFF242729)),
                          foregroundColor: MaterialStateProperty.all(
                              const Color(0xFFDEDEDE)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: _updateUserProfileImage,
                        child: const Text(
                          'Зберегти зміни',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
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

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 80,
        backgroundColor: Colors.grey[800],
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: Image.file(
                  _image!,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              )
            : userData['profile_image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.network(
                      userData['profile_image'],
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileExtension = pickedFile.path.split('.').last.toLowerCase();
      final isGIF = fileExtension == 'gif';

      if (isPremium || (!isPremium && !isGIF)) {
        File selectedImage = File(pickedFile.path);

        if (!isGIF) {
          selectedImage = await _compressImage(selectedImage);
        }

        setState(() {
          _image = selectedImage;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Для встановлення анімованого фото профілю необхідний преміум план.'),
          ),
        );
      }
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

  Future<void> _updateUserProfileImage() async {
    bool isDataChanged = false;

    if (_image != null) {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('profile_images');
      String fileName = '${user!.uid}.jpg';
      final TaskSnapshot uploadTask =
          await storageRef.child(fileName).putFile(_image!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .update({
        'profile_image': imageUrl,
      });

      isDataChanged = true;
    }

    final String? newNickname = _nicknameController.text.trim();
    if (newNickname != null && newNickname.isNotEmpty) {
      final existingNicknameQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('nickname', isEqualTo: newNickname)
          .get();

      if (existingNicknameQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Цей нікнейм вже використовується, оберіть інший!'),
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .update({
          'nickname': newNickname,
        });

        isDataChanged = true;
        _nicknameController.clear();
      }
    }
    if (isDataChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дані успішно змінено!'),
        ),
      );
    }
  }
}
