
import 'package:WODaily/model/workout.dart';
import 'package:WODaily/screens/timer_screen.dart';
import 'package:WODaily/services/auth.dart';
import 'package:WODaily/services/database.dart';
import 'package:WODaily/utils/db_helper_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'edit_screen.dart';
import 'enter_screen.dart';

class WodHome extends StatefulWidget {

  @override
  _WodHomeState createState() => _WodHomeState();
}

class _WodHomeState extends State<WodHome> {
  final List<Wod> _wodList = <Wod>[]; // Deprecated
  int _month = DateTime.now().month;
  var db=DatabaseHelper();
  List<bool> _isSelected = [true, false];
  bool _calendarMode = false;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  Map<DateTime,List<QueryDocumentSnapshot<Object>>> _calendarWods;
  DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.sss');

  List<QueryDocumentSnapshot> _getWodsForDay(DateTime date){
    date = DateTime.parse(_dateFormat.format(date));
    return _calendarWods[date] ?? [];
  }

  @override
  void initState(){
    _calendarWods = {};
    super.initState();
  }

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: StreamBuilder(
          stream: DatabaseService().dbwodsByMonth(_month),
          builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator()
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: ToggleButtons(
                          constraints: BoxConstraints(
                            minWidth: (MediaQuery
                                .of(context)
                                .size
                                .width - 3) / 2,
                            minHeight: 40.0,
                          ),
                          children: [
                            Icon(FontAwesomeIcons.listUl),
                            Icon(FontAwesomeIcons.calendar),
                          ],
                          isSelected: _isSelected,
                          onPressed: (int index) {
                            setState(() {
                              for (int i = 0; i < _isSelected.length; i++) {
                                _isSelected[i] = i == index;
                                if (index == 1) {
                                  _calendarMode = true;
                                } else {
                                  _calendarMode = false;
                                }
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  _calendarMode ? getCalenderView(snapshot) : getListView(snapshot),
                ],
              ),
            );
          },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: "Add",
          elevation: 10,
          onPressed:() async {
            await Navigator.push(context, MaterialPageRoute(
                builder: (context) => EnterWodScreen()
            ));
          }
      ),
    );
  }

  Widget getCalenderView(AsyncSnapshot<QuerySnapshot<Object>> snapshot){
    updateCalendar(snapshot);
    return Column(
      children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2050),
            calendarFormat: format,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onFormatChanged: (CalendarFormat _format){
              setState(() {
                format = _format;
              });
            },

            onPageChanged: (DateTime focusedDay){
              setState(() {
                selectedDay = focusedDay;
                _month = focusedDay.month;
                print('onPageChanged ' + _month.toString() + ', ' + selectedDay.toString());
              });
            },

            eventLoader: (day) {
              return _getWodsForDay(day);
            },

            // Header format
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false
            ),

            // Day selected
            onDaySelected: (DateTime selectDay, DateTime focusDay){
              setState(() {
                print('onDaySelected');
                selectedDay = selectDay;
                focusedDay = focusDay;
              });
              print(focusedDay);
            },
            selectedDayPredicate: (DateTime date){
              return isSameDay(selectedDay,date);
            },

            // Calendar Style
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedTextStyle: TextStyle(color: Colors.white),

              defaultDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),

              outsideDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),

              markerDecoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),

              weekendDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),

              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),

              todayDecoration: BoxDecoration(
                  color: Colors.blueGrey.shade300,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
        ..._getWodsForDay(selectedDay).map((wodSnapshot) => Card(
          elevation: 5,
          margin: EdgeInsets.all(3),
          shape:const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          child: ListTile(
              title: Text(DateFormat('MM/dd/yy').format(wodSnapshot['date'].toDate())),
              subtitle: Text(wodSnapshot['type'] + ":" + wodSnapshot['description'], style: const TextStyle(fontSize: 16.0),),
              trailing: Text(wodSnapshot['score']),

              onTap: () async {
                await Navigator.push(this.context,MaterialPageRoute(
                    builder: (context) => EditWodScreen(workout: wodSnapshot)
                ));
              },

              onLongPress: () => showDialog<String>(
                  context: this.context,
                  builder: (BuildContext) => AlertDialog(
                    title: const Text("Delete Workout?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(this.context, 'Delete');
                          print(wodSnapshot.id);
                          DatabaseService().deleteWod(wodSnapshot.id);
                        },
                        child: const Text('Delete'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(this.context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
              )
            ),
        ),
        )
      ]
    );
  }

  Widget getListView(AsyncSnapshot<QuerySnapshot<Object>> snapshot){
    return Expanded(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _month = (_month == 1) ? 12 : _month-1;
                    //getData();
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
                    //getData();
                  });
                },
                icon: const Icon(FontAwesomeIcons.angleDoubleRight),
              ),
            ],
          ),
          Expanded(
            child: Container(
              child: ListView(
                children: snapshot.data.docs.map((wodSnapshot) {
                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.all(3),
                    shape:const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: ListTile(
                      // Might not need the year here if we are showing monthly
                        title: Text(DateFormat('MM/dd/yy').format(wodSnapshot['date'].toDate()),
                                  style:  const TextStyle(fontSize: 20.0),),
                        subtitle: Text(wodSnapshot['description'],
                                    style:  const TextStyle(fontSize: 20.0),),
                        trailing: Text(wodSnapshot['score'],
                                    style:  const TextStyle(fontSize: 20.0),),
                        onTap: () async {
                          await Navigator.push(this.context,MaterialPageRoute(
                              builder: (context) => EditWodScreen(workout: wodSnapshot)
                          ));
                        },

                        onLongPress: () => showDialog<String>(
                            context: this.context,
                            builder: (BuildContext) => AlertDialog(
                              title: const Text("Delete Workout?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(this.context, 'Delete');
                                    print(wodSnapshot.id);
                                    DatabaseService().deleteWod(wodSnapshot.id);
                                  },
                                  child: const Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(this.context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            )
                        )
                    ),
                  );
                }).toList(),
              ),
            )
          ),
        ]
      ),
    );
  }

  /*
  Deprecated now that we are using a stream for the firestore database
   */
  getData() async {
    // Will have to incorporate year here eventually to
    // prevent past years data from populating into current year
    _wodList.clear();
    print('Getting data for month: $_month');
    List wods = await db.getMonthData(_month);
    for (var wod in wods) {
      setState(() {
        _wodList.add(Wod.fromMap(wod));
      });
    }
  }

  void updateCalendar(AsyncSnapshot<QuerySnapshot<Object>> snapshot) {
    _calendarWods.clear();
    for(var wod in snapshot.data.docs){
        DateTime date = wod['date'].toDate();
        if (_calendarWods[date]!=null) {
          _calendarWods[date].add(wod);
        } else {
          _calendarWods[date] = [wod];
        }
    }
  }

  /*
  Deprecated now that we are using firestore
   */
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
        Navigator.of(this.context).push(MaterialPageRoute(
            builder: (context) => TimerScreen()));
        break;
      case 'Search':
        break;
    }
  }
}