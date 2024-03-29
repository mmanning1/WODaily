import 'package:WODaily/model/user.dart';
import 'package:WODaily/model/workout.dart';
import 'package:WODaily/screens/wrapper.dart';
import 'package:WODaily/services/auth.dart';
import 'package:WODaily/services/database.dart';
import 'package:WODaily/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<WodUser>.value(
          value: AuthService().user,
        ),
      ],
      child: MaterialApp(
        title: 'WODaily',
        debugShowCheckedModeBanner: false,
        theme: mainThemeData,
        home: Wrapper(),
      ),
    );
  }
}
