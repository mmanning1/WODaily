
import 'package:WODaily/model/workout.dart';
import 'package:WODaily/screens/timer_screen.dart';
import 'package:WODaily/services/auth.dart';
import 'package:WODaily/services/database.dart';
import 'package:WODaily/utils/db_helper_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'edit_screen.dart';
import 'enter_screen.dart';

class WodHome extends StatefulWidget {

  @override
  _WodHomeState createState() => _WodHomeState();
}

class _WodHomeState extends State<WodHome> {
  final List<Wod> _wodList = <Wod>[];
  int _month = DateTime.now().month;
  var db=DatabaseHelper();

  @override
  void initState(){
    super.initState();
    getData();
  }

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot>.value(
      value: DatabaseService().dbusers, //this part needs to be the wods
      child: Scaffold(
        appBar: AppBar(
          title: const Text("WODaily"),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(FontAwesomeIcons.bars),
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Logout', 'Settings','Timer'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _month = (_month == 1) ? 12 : _month-1;
                        getData();
                      });
                    },
                    icon: const Icon(FontAwesomeIcons.angleDoubleLeft),
                  ),
                  Expanded(
                    child: Text(DateFormat('MMMM').format(DateTime(0,_month)),
                        textAlign: TextAlign.center,
                        textScaleFactor: 2),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _month = (_month == 12) ? 1 : _month+1;
                        getData();
                      });
                    },
                    icon: const Icon(FontAwesomeIcons.angleDoubleRight),
                  ),
                ],

              ),
              Expanded(
                // final wods = Provider.of<QuerySnapshot>(context);
                // put in wod model and for loop
                  child: ListView.builder(
                      itemCount: _wodList.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context,int index){
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.all(3),
                          shape:const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          child: ListTile(
                            // Might not need the year here if we are showing monthly
                              title: Text(DateFormat('MM/dd/yy').format(DateTime.parse(_wodList[index].date)),
                                style:  const TextStyle(fontSize: 20.0),),
                              subtitle: Text(_wodList[index].type + ': ' + _wodList[index].description,
                                style:  const TextStyle(fontSize: 10.0),),
                              trailing: Text(_wodList[index].score,
                                  style:  const TextStyle()),
                              onTap: () async {
                                final Wod editedWod = await Navigator.push(context,MaterialPageRoute(
                                    builder: (context) => EditWodScreen(workout: _wodList[index], index: index)
                                ));
                                setState(() {
                                  if (editedWod != null) {
                                    _wodList[index] = editedWod;
                                  }
                                });
                              },
                              onLongPress: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext) => AlertDialog(
                                    title: const Text("Delete Workout?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, 'Delete');
                                          _delete(_wodList[index].id,index);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  )
                              )
                          ),
                        );
                      }
                  )
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            tooltip: "Add",
            elevation: 10,
            onPressed:() async {
              final Wod newWod = await Navigator.push(context, MaterialPageRoute(
                  builder: (context) => EnterWodScreen()
              ));
              setState(() {
                // In case they pressed cancel
                if (newWod != null) {
                  //In case they entered a workout for a different month
                  if (DateFormat('yyyy-MM-dd').parse(newWod.date).month == _month) {
                    _wodList.insert(0, newWod);
                  }
                }
              });
            }
        ),
      ),
    );
  }

  getData() async {
    // Will have to incorporate year here eventually to
    // prevent past years data from populating into current year
    _wodList.clear();
    print('Getting data for month: $_month');
    List wods = await db.getMonthData(_month);
    for (var element in wods) {
      setState(() {
        //print('Populating list with: ' + element.toString());
        _wodList.add(Wod.fromMap(element));
      });
    }
  }

  void _delete(int id, int index) async {
    print('Deleting wod with id: $id');
    db.deleteItem(id);
    setState(() {
      _wodList.removeAt(index);
    });
  }

  Future handleClick(String value) async {
    switch (value) {
      case 'Logout':
        await _auth.signOut();
        break;
      case 'Settings':
        break;
      case 'Timer':
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TimerScreen()));
        break;
      case 'Search':
        break;
    }
  }
}