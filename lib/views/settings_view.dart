import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/user_profile_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  User? user = FirebaseAuth.instance.currentUser;
  File? _image;
  var userData;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(user!.uid).snapshots(),
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
          title: const Text('Змінити профіль',
          style: 
            TextStyle(color: Color(0xFFD3D3D3),),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), 
            color: const Color(0xFFD3D3D3),
            onPressed: (){
              Navigator.pushReplacement(context, CustomPageRoute(
              builder: (context) => const UserProfile(),
              ));
            },
          )
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 20)),
                _buildAvatar(),
                const Padding(padding: EdgeInsets.only(top: 5)),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF242729)),
                      foregroundColor: MaterialStateProperty.all(
                        const Color(0xFFDEDEDE),
                      ),
                    ),
                    onPressed: _pickImage,
                    child: const Text('Змінити фото'),
                  ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF242729)),
                    foregroundColor: MaterialStateProperty.all(
                      const Color(0xFFDEDEDE),
                    ),
                  ),
                  onPressed: _updateUserProfileImage,
                  child: const Text('Зберегти зміни'),
                ),
            ],
            ),
          ),
        )
        );
        }
      }
    );
  }
  Widget _buildAvatar() {
  return GestureDetector(
    onTap: _pickImage,
    child: CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[800],
      child: _image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.file(
                _image!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            )
            : userData['profile_image'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    userData['profile_image'],
                    width: 120,
                    height: 120,
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
  Future<void> _updateUserProfileImage() async {
    if(_image != null){
      // Отримання посилання на Firebase Storage та завантаження нового зображення
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_images');
      String fileName = '${user!.uid}.jpg';
      final TaskSnapshot uploadTask = await storageRef.child(fileName).putFile(_image!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Оновлення посилання на зображення в базі даних Firestore
      await FirebaseFirestore.instance.collection('Users').doc(user!.uid).update({
        'profile_image': imageUrl,
      });
    }
}
}