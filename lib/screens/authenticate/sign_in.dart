
import 'package:WODaily/screens/authenticate/register.dart';
import 'package:WODaily/services/auth.dart';
import 'package:WODaily/shared/constants.dart';
import 'package:WODaily/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  bool _loading = false;
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return _loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.blue.shade900,
      ),
      resizeToAvoidBottomInset: false, // prevents overflow
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              SizedBox(height: 20.0),
              TextFormField(
                // Username/email
                decoration: textInputDecoration.copyWith(hintText: 'Email'),
                validator: (val) {
                  final pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
                  final regExp = RegExp(pattern);

                  //val.isEmpty ? 'Enter email' : null,
                  if(!regExp.hasMatch(val)){
                    return 'Enter a Valid Email';
                  } else {
                    return null;
                  }
                },
                onChanged: (val){
                  setState(() {
                    return email = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                //password
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                obscureText: true,
                validator: (val) => val.length<6 ? 'At least 6 characters long' : null,
                onChanged: (val){
                  setState(() {
                    return password = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ButtonStyle(

                ),
                onPressed: () async {
                  if(_formkey.currentState.validate()){
                    setState(() => _loading = true);
                    //await Future.delayed(Duration(seconds: 2));
                    dynamic result = await _auth.signIn(email, password);
                    if(result==null){
                      setState(() {
                        error = 'Could not sign in';
                        _loading = false;
                      });
                    }
                  }
                },
                child: Text('Sign In')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Dont have an account? "),
                  TextButton(
                    child: Text("Sign up"),
                    onPressed: () async {
                      final user = await Navigator.push(context,MaterialPageRoute(
                          builder: (context) => Register()
                      ));
                    },
                  )
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                  children: <Widget>[
                    Expanded(
                        child: Divider(
                          thickness: 1,
                          endIndent: 10,
                        )
                    ),
                    Text('OR'),
                    Expanded(
                        child: Divider(
                          indent: 10,
                          thickness: 1,
                        )
                    ),
                  ]
              ),
              SizedBox(height: 10.0),
              SignInButton(
                  Buttons.GoogleDark,
                  text: "   Sign in with Google",

                  onPressed: () async {
                    setState(() => _loading = true);
                    dynamic result = await _auth.signInGoogle();
                    if(result==null){
                      setState(() {
                        error = 'Could not sign into Google';
                        _loading = false;
                      });
                    }
                  }),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
