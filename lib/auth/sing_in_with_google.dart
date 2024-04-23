import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

Future<bool> signInWithGoogle() async {
  try {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn
        .signOut(); // Вихід зі всіх облікових записів перед входом

    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
        .signIn(); // Відобразити вікно вибору облікового запису Google

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return true; // Успішно увійшли в обліковий запис
    }
  } catch (error) {
    print('Failed to sign in with Google: $error');
  }
  return false; // Не вдалося увійти в обліковий запис
}

Future<bool> signOut() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Вихід з облікового запису Google
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Вихід з облікового запису Facebook
    // final FacebookLogin facebookLogin = FacebookLogin();
    // await facebookLogin.logOut();

    // Вихід з Firebase
    await auth.signOut();

    return true; // Успішно вийшли з облікового запису
  } catch (error) {
    return false; // Не вдалося вийти з облікового запису
  }
}
