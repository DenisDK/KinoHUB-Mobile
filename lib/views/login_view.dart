import 'package:flutter/material.dart';
import 'package:kinohub/auth/sing_in_with_google.dart';
import 'package:kinohub/routes/routes.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 325,
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
                            // Стиль "Kino"
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
                  const SizedBox(height: 25),
                  Text(
                    'Щоб ви змогли вільно користуватися додатком треба увійти в свій Google аккаунт',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      color: const Color(0xFF959595),
                    ),
                  ),

                  const SizedBox(
                      height: 25), // Збільшено відступ між текстом та кнопкою
                  ElevatedButton(
                    onPressed: () async {
                      bool userLogin = await signInWithGoogle();
                      if (userLogin) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          mainMenuRoute,
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Не вдалося увійти в аккаунт Google'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 45),
                      backgroundColor: const Color(0xFFD9D9D9), // колір кнопки
                      foregroundColor: const Color(0xFF000000), // колір тексту
                    ),
                    child: const Text('Увійти через Google'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
