import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

Future<bool> signInWithGoogle() async {
  try {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn
        .signOut(); 

    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
        .signIn(); 

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      return true; 
    }
  } catch (error) {
    print('Failed to sign in with Google: $error');
  }
  return false; 
}

Future<bool> signOut() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;


    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    await auth.signOut();

    return true; 
  } catch (error) {
    return false; 
  }
}
