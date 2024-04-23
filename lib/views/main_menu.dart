import 'package:flutter/material.dart';
import 'package:kinohub/auth/sing_in_with_google.dart';
import 'package:kinohub/components/alert_dialog_custom.dart';
import 'package:kinohub/routes/routes.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 350,
                decoration: BoxDecoration(
                  color: const Color(0xFF43484F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          TextSpan(
                            text: 'Kino',
                            style: TextStyle(
                              color: const Color(0xFFD3D3D3),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'HUB',
                            style: TextStyle(
                              color: const Color(0xFFFF5200),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 45),
                    ElevatedButton(
                      onPressed: () async {
                        bool? result =
                            await CustomDialogAlert.showConfirmationDialog(
                          context,
                          'Вихід з аккаунту',
                          'Ви впевнені, що хочете вийти з аккаунту?',
                        );
                        if (result != null && result) {
                          bool isUserSingOut = await signOut();
                          if (isUserSingOut) {
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
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 45),
                        backgroundColor: const Color(0xFFD9D9D9),
                        foregroundColor: const Color(0xFF000000),
                      ),
                      child: const Text('Вийти'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
