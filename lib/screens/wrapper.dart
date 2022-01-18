import 'package:WODaily/main.dart';
import 'package:WODaily/model/user.dart';
import 'package:WODaily/screens/authenticate/authenticate.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';

class Wrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<WodUser>(context);
    print('User: ' + user.toString());

    if(user==null){
      return Authenticate();
    } else {
      return WodHome();
    }
    return Authenticate();
  }

}