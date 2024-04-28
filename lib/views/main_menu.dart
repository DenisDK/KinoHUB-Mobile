import 'package:flutter/material.dart';
import 'package:kinohub/components/drop_down__for_main%20_menu.dart';

import 'search_view.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF262626),
        title: Row(
          children: [
            Image.asset(
              'lib/images/logo.png', // шлях до вашого зображення логотипу
              height: 35, // Висота зображення
              width: 35, // Ширина зображення
            ),
            const SizedBox(width: 10), // Простір між логотипом і текстом
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Roboto',
                ),
                children: [
                  TextSpan(
                    text: 'Kino',
                    style: TextStyle(
                      color: Color(0xFFD3D3D3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'HUB',
                    style: TextStyle(
                      color: Color(0xFFFF5200),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieSearchScreen()),
                );
              }
            },
            icon: Icon(
              Icons.search,
              color: const Color(0xFFDEDEDE),
            ),
          ),
          GestureDetector(
            onTap: () {
              showPopupMenu(context);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E), // колір прямокутника
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        // Використовуємо Stack для розташування прямокутника
        children: [
          Positioned(
            top: 20.0, // Позиціонуємо прямокутник відносно верхнього краю
            left: 20.0, // Відступ зліва
            right: 20.0, // Відступ зправа
            child: Container(
              height: 30.0,
              decoration: BoxDecoration(
                color: const Color(0xFF3C8399), // Колір прямокутника
                borderRadius: BorderRadius.circular(8.0), // Закруглені кути
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Container(
                      width: 5.0,
                      color: const Color(0xFF62A4AD),
                    ),
                  ),
                  SizedBox(width: 10), // Відступ між полоскою і текстом
                  Text(
                    'Новинки кіно',
                    style: TextStyle(
                      color: const Color(0xFF171515),
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
