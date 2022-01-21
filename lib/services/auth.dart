import 'package:WODaily/model/user.dart';
import 'package:WODaily/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get our local user rather than a firebase user object
  WodUser _userFromFirebase(User firebaseUser){
    if(firebaseUser != null){
      String name = firebaseUser.displayName;
      String first = name.substring(0,name.indexOf(' '));
      String last = name.substring(name.indexOf(' ')).trim();
      return WodUser(uid: firebaseUser.uid, firstName: first, lastName: last, email: firebaseUser.email);
    } else {
      return null;
    }
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
  Future register(String email, String password, String lastNm, String firstNm) async {
    try{
      UserCredential firebaseUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = firebaseUser.user;
      user.updateDisplayName(firstNm + ' ' + lastNm);

      //need to reload to print details
      //await user.reload();
      //user = await _auth.currentUser;

      //create user in firestore db
      await DatabaseService(uid: user.uid).updateUserData(lastNm, firstNm);

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

      String name = googleUser.displayName;
      String first = name.substring(0,name.indexOf(' '));
      String last = name.substring(name.indexOf(' ')).trim();

      await DatabaseService(uid: firebaseGoogleUser.user.uid).updateUserData(last, first);

      return _userFromFirebase(firebaseGoogleUser.user);
    } catch(e) {
      print(e.toString());
    }
  }

}