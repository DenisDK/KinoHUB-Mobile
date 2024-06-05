import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/firebase_options.dart';
import 'package:kinohub/views/friend_profile_view.dart';
import 'package:kinohub/views/main_menu.dart';
import 'package:kinohub/views/premium_view.dart';
import 'package:kinohub/views/register_view.dart';
import 'package:kinohub/views/search_view.dart';
import 'package:kinohub/views/settings_view.dart';
import 'package:kinohub/views/user_profile_view.dart';
import 'routes/routes.dart';
import 'views/login_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: "api_key.env");
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? token = await messaging.getToken();

  runApp(
    MaterialApp(
      title: 'KinoHUB',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF202020),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF262626),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        mainMenuRoute: (context) => const MainMenu(),
        searchRoute: (context) => const MovieSearchScreen(),
        userProfileRoute: (context) => const UserProfile(),
        userRegistrationRoute: (context) => const RegistrationView(),
        settingsRoute: (context) => const SettingsView(),
        premiumRoute: (context) => PremiumView(
              userId: '',
            ),
        friendProfileRoute: (context) => const FriendProfileView(
              friendId: '',
            ),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid)
                  .get()
                  .then((userData) {
                if (userData.exists && userData['nickname'] != null) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    mainMenuRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    CustomPageRoute(
                      builder: (context) => const RegistrationView(),
                    ),
                  );
                }
              });
            } else {
              return const LoginView();
            }
            break;
          default:
            return Scaffold(
              backgroundColor: Colors.grey[200],
              body: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 62, 66, 68)),
                ),
              ),
            );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
