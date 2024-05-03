import 'package:flutter/material.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/views/main_menu.dart';
import 'package:kinohub/views/search_view.dart';
import 'package:kinohub/views/user_profile_view.dart';

class MainBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final void Function(int index) onTap;

  MainBottomNavigationBar({
    required this.selectedIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _MainBottomNavigationBarState createState() =>
      _MainBottomNavigationBarState();
}

class _MainBottomNavigationBarState extends State<MainBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF262626),
      currentIndex: widget.selectedIndex,
      onTap: (index) {
        widget.onTap(index);

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                builder: (context) => const MainMenu(),
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                builder: (context) => MovieSearchScreen(),
              ),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                builder: (context) => UserProfile(),
              ),
            );
            break;
        }
      },
      selectedItemColor: const Color(0xFFFF5200),
      unselectedItemColor: const Color(0xFFDEDEDE),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Головна',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Пошук',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Профіль',
        ),
      ],
    );
  }
}
