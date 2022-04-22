import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  FirebaseAuth _firebaseAuth;
  User _user;

  static final Auth _instance = Auth.internal();

  factory Auth() {
    return _instance;
  }

  Auth.internal() {
    _firebaseAuth = FirebaseAuth.instance;
  }

  Future<bool> isLoggedIn() async {
    _user = _firebaseAuth.currentUser;
    if (_user == null) {
      return false;
    }
    return true;
  }

  void signOut() async {
    _firebaseAuth.signOut();
  }

  Future<bool> authenticateWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final User user =
        (await _firebaseAuth.signInWithCredential(credential)).user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _firebaseAuth.currentUser;
    assert(user.uid == currentUser.uid);
    return user != null;
  }

  Future<String> getLoggedInEmail() async {
    final User currentUser = _firebaseAuth.currentUser;
    return currentUser.email;
  }
}
