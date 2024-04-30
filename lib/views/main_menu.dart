import 'package:flutter/material.dart';
import 'package:kinohub/auth/sing_in_with_google.dart';
import 'package:kinohub/components/alert_dialog_custom.dart';
import 'package:kinohub/routes/routes.dart';
import '../components/bottom_appbar_custom.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF262626),
        title: Row(
          children: [
            Image.asset(
              'lib/images/logo.png',
              height: 35,
              width: 35,
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
            icon: Icon(
              Icons.exit_to_app,
              color: const Color(0xFFDEDEDE),
            ),
            onPressed: () {
              _handleSignOut(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              height: 30.0,
              decoration: BoxDecoration(
                color: const Color(0xFF3C8399),
                borderRadius: BorderRadius.circular(8.0),
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
      bottomNavigationBar: MainBottomNavigationBar(
        selectedIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  void _handleSignOut(BuildContext context) async {
    bool? result = await CustomDialogAlert.showConfirmationDialog(
      context,
      'Вихід з аккаунту',
      'Ви впевнені, що хочете вийти з аккаунту?',
    );
    if (result != null && result) {
      bool isUserSignOut = await signOut();
      if (isUserSignOut) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не вдалося вийти з аккаунту'),
        ),
      );
    }
  }
}
