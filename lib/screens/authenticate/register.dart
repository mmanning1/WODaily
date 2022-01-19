

import 'package:WODaily/model/user.dart';
import 'package:WODaily/services/auth.dart';
import 'package:WODaily/shared/constants.dart';
import 'package:WODaily/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  bool _loading = false;
  String firstnm = '';
  String lastnm = '';
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return _loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: Colors.blue.shade900,
      ),
      resizeToAvoidBottomInset: false, // prevents overflow
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'First Name'),
                validator: (val) => val==null ? "Enter you last name" : null,
                onChanged: (val){
                  setState(() {
                    return firstnm = val;
                  });
                },
              ),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Last Name'),
                validator: (val) => val==null ? "Enter you last name" : null,
                onChanged: (val){
                  setState(() {
                    return lastnm = val;
                  });
                },
              ),
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
                      print('Email: ' + email);
                      print('Password: ' + password);
                      dynamic result = await _auth.register(email, password, lastnm, firstnm);
                      if(result==null){
                        setState(() {
                          error = 'Please supply a valid email';
                          _loading = false;
                        });
                      } else {
                        Navigator.pop(context);
                        print('Success ' + result.toString());
                      }
                    }
                  },
                  child: Text('Register')
              ),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
