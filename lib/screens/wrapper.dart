import 'package:WODaily/model/user.dart';
import 'package:WODaily/model/workout.dart';
import 'package:WODaily/screens/authenticate/authenticate.dart';
import 'package:WODaily/services/auth.dart';
import 'package:WODaily/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class Wrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<WodUser>(context);

    if(user==null){
      return Authenticate();
    } else {
      return WodHome();
    }
  }

}