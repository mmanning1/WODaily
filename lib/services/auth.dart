
import 'package:WODaily/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get our local user rather than a firebase user object
  // do we need this??
  WodUser _userFromFirebase(User firebaseUser){
    return firebaseUser != null ? WodUser(uid: firebaseUser.uid, email: firebaseUser.email) : null;
  }

  //auth change stream
  Stream<WodUser> get user {
    return _auth.authStateChanges()
        //.map((User user) => _userFromFirebase(user));
        .map(_userFromFirebase);
  }

  //sign in with email and pw
  Future signIn(String email, String password) async {
    try{
      UserCredential firebaseUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebase(firebaseUser.user);
    }catch(e){
      print(e.toString());
    }
  }

  //register
  Future register(String email, String password) async {
    try{
      UserCredential firebaseUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return _userFromFirebase(firebaseUser.user);
    }catch(e){
      print(e.toString());
    }
  }

  //signout
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch (e){
      print(e.toString());
      return null;
    }
  }

  Future signInGoogle() async {
    try{
      final googleUser = await googleSignIn.signIn();
      if (googleUser==null) return;
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential firebaseGoogleUser = await _auth.signInWithCredential(credential);
      return _userFromFirebase(firebaseGoogleUser.user);
    } catch(e) {
      print(e.toString());
    }
  }

}