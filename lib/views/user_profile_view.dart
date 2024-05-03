import 'package:flutter/material.dart';
import 'package:kinohub/components/bottom_appbar_custom.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      bottomNavigationBar: MainBottomNavigationBar(
        selectedIndex: 2,
        onTap: (index) {},
      ),
    );
  }
}
