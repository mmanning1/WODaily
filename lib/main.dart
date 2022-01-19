import 'package:WODaily/model/user.dart';
import 'package:WODaily/screens/authenticate/sign_in.dart';
import 'package:WODaily/screens/wrapper.dart';
import 'package:WODaily/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:WODaily/screens/enter_screen.dart';
import 'package:WODaily/utils/db_helper_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'model/workout.dart';
import 'screens/edit_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<WodUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'WODaily',
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
