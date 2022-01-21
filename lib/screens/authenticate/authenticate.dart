import 'package:WODaily/screens/authenticate/sign_in.dart';
import 'package:flutter/cupertino.dart';

class Authenticate extends StatefulWidget{
  @override
  _AuthenticateState createState() => _AuthenticateState();
}


class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  @override
  Widget build(BuildContext context){
    return Container(
      child: SignIn(),
    );
  }
}