import 'package:flutter/material.dart';
import 'package:kinohub/auth/sing_in_with_google.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kinohub/views/register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 350,
              height: 420,
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        TextSpan(
                          text: 'Kino',
                          style: TextStyle(
                            // Стиль "Kino"
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
                  const SizedBox(height: 25),
                  const Text(
                    'Щоб ви змогли вільно користуватися додатком, треба увійти в свій Google аккаунт',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      color: Color(0xFF959595),
                    ),
                  ),

                  const SizedBox(height: 25), // Відступ між текстом та кнопкою
                  ElevatedButton(
                    onPressed: () async {
                      bool userLogin = await signInWithGoogle();
                      if (userLogin) {
                        // Отримання поточного користувача
                        final user = FirebaseAuth.instance.currentUser;

                        // Перевірка наявності нікнейму та колекцій фільмів у базі даних Firebase
                        DocumentSnapshot userData = await FirebaseFirestore
                            .instance
                            .collection('Users')
                            .doc(user?.uid)
                            .get();
                        if (userData.exists && userData['nickname'] != null) {
                          // Якщо є нікнейм та колекції фільмів, переходимо на головну сторінку
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            mainMenuRoute,
                            (route) => false,
                          );
                        } else {
                          // Якщо немає нікнейму або колекцій фільмів, переходимо на сторінку реєстрації
                          Navigator.pushReplacement(
                            context,
                            CustomPageRoute(
                              builder: (context) => const RegistrationView(),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Не вдалося увійти в аккаунт Google'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: const Color(0xFF242729), // колір кнопки
                      foregroundColor: const Color(0xFFDEDEDE), // колір тексту
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
