import 'package:flutter/material.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/user_profile_view.dart';

class FriendProfileView extends StatefulWidget {
  const FriendProfileView({Key? key}) : super(key: key);

  @override
  State<FriendProfileView> createState() => _FriendProfileViewState();
}

class _FriendProfileViewState extends State<FriendProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Профіль друга',
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
    );
  }
}
