
import 'package:WODaily/model/user.dart';
import 'package:WODaily/model/workout.dart';
import 'package:WODaily/screens/edit_screen_local.dart';
import 'package:WODaily/screens/tabata_screen.dart';
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
import 'package:WODaily/shared/constants.dart';

import 'edit_screen.dart';
import 'enter_screen.dart';

class WodHome extends StatefulWidget {

  @override
  _WodHomeState createState() => _WodHomeState();
}

class _WodHomeState extends State<WodHome> {
  final List<Wod> _wodList = <Wod>[]; // Deprecated
  var user = new WodUser();
  int _month = DateTime.now().month;
  var db=DatabaseHelper();
  List<bool> _isSelected = [true, false];
  bool _calendarMode = false;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  Map<DateTime,List<QueryDocumentSnapshot<Object>>> _calendarWods;
  Map<DateTime,List<Wod>> _calendarWodsLocal;
  DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.sss');

  //For firebase storage
  List<QueryDocumentSnapshot> _getWodsForDay(DateTime date){
    date = DateTime.parse(_dateFormat.format(date));
    return _calendarWods[date] ?? [];
  }

  //For local storage
  List<Wod> _getWodsForDayLocal(DateTime date){
    date = DateTime.parse(_dateFormat.format(date));
    return _calendarWodsLocal[date] ?? [];
  }

  @override
  void initState(){
    _calendarWods = {};
    _calendarWodsLocal = {};
    super.initState();
    if (!useFirebase) {
      getData();
      updateCalendarLocal();
    }
  }

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    user = Provider.of<WodUser>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("WODaily"),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(FontAwesomeIcons.bars),
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Logout', 'Settings','Stopwatch','Tabata'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: (useFirebase ? buildStream() : buildLocal(context)),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: "Add",
          elevation: 10,
          onPressed:() async {
            await Navigator.push(context, MaterialPageRoute(
                builder: (context) => EnterWodScreen(date: selectedDay)
            ));
            setState(() {
              getData();
            });
          }
      ),
    );
  }

  Widget buildLocal(BuildContext context) {
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
                          selectedDay = DateTime.now(); // so that the correct default date in list mode
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          _calendarMode ? getCalenderViewLocal() : getListViewLocal(),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object>> buildStream() {
    return StreamBuilder(
        stream: DatabaseService().dbwodsByMonth(_month, user.uid),
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
    );
  }

  Widget getCalenderViewLocal() {
    return FutureBuilder<Map<DateTime,List<Wod>>>(
      future: updateCalendarLocal(),
      builder: (BuildContext context, AsyncSnapshot<Map<DateTime,List<Wod>>> snapshot) {
        _calendarWodsLocal = snapshot.data ?? {};
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
                    //updateCalendarLocal();
                  });
                },

                eventLoader: (day) {
                  return _getWodsForDayLocal(day);
                },

                // Header format
                headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false
                ),

                // Day selected
                onDaySelected: (DateTime selectDay, DateTime focusDay){
                  setState(() {
                    selectedDay = selectDay;
                    focusedDay = focusDay;
                  });
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
              ..._getWodsForDayLocal(selectedDay).map((wodSnapshot) => Card(
                elevation: 5,
                margin: EdgeInsets.all(3),
                shape:const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: ListTile(
                    title: Text(DateFormat('MM/dd/yy').format(DateTime.parse(wodSnapshot.date))),
                    subtitle: Text(wodSnapshot.type + ":" + wodSnapshot.description, style: const TextStyle(fontSize: 16.0),),
                    trailing: Text(wodSnapshot.score),

                    onTap: () async {
                      await Navigator.push(this.context,MaterialPageRoute(
                          builder: (context) => EditWodScreenLocal(workout: wodSnapshot)
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
                                setState(() {
                                  print('Deleting wod with id: ' + wodSnapshot.id.toString());
                                  db.deleteItem(wodSnapshot.id);
                                  _calendarWodsLocal.remove(DateTime.parse(wodSnapshot.date));
                                });
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
    );
  }

  Widget getListViewLocal() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            // Just so that the headers look the same
            // Maybe copy the table_calender's header style?
            width: double.infinity,
            height: 8,
          ),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _month = (_month == 1) ? 12 : _month-1;
                    getData();
                  });
                },
                padding: const EdgeInsets.only(left: 16.0),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(DateFormat('MMMM').format(DateTime(0,_month)),
                    style: const TextStyle(fontSize: 17.0),
                    textAlign: TextAlign.center),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _month = (_month == 12) ? 1 : _month+1;
                    getData();
                  });
                },
                padding: const EdgeInsets.only(right: 16.0),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: _wodList.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index){
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
                        subtitle: Text(_wodList[index].description,
                          style:  const TextStyle(fontSize: 20.0),),
                        trailing: Text(_wodList[index].score,
                          style:  const TextStyle(fontSize: 20.0),),
                        onTap: () async {
                          await Navigator.push(this.context,MaterialPageRoute(
                              builder: (context) => EditWodScreenLocal(workout: _wodList[index])
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
                                    setState(() {
                                      print('Deleting wod with id: ' + _wodList[index].id.toString());
                                      db.deleteItem(_wodList[index].id);
                                      _wodList.removeAt(index);
                                    });
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
                },
              ),
            ),
          ),
        ],
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
                          DatabaseService().deleteWod(wodSnapshot.id, user.uid);
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
          SizedBox(
            // Just so that the headers look the same
            // Maybe copy the table_calender's header style?
            width: double.infinity,
            height: 8,
          ),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _month = (_month == 1) ? 12 : _month-1;
                  });
                },
                padding: const EdgeInsets.only(left: 16.0),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(DateFormat('MMMM').format(DateTime(0,_month)),
                    style: const TextStyle(fontSize: 17.0),
                    textAlign: TextAlign.center),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _month = (_month == 12) ? 1 : _month+1;
                    //getData();
                  });
                },
                padding: const EdgeInsets.only(right: 16.0),
                icon: const Icon(Icons.chevron_right),
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
                                    DatabaseService().deleteWod(wodSnapshot.id, user.uid);
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

  void getData() async {
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

  Future<Map<DateTime,List<Wod>>> updateCalendarLocal() async {
    _calendarWodsLocal.clear();
    List monthData = await db.getMonthData(_month);
    for (var wod in monthData) {
      DateTime date = DateTime.parse(wod['date']);
      if (_calendarWodsLocal[date] != null) {
        _calendarWodsLocal[date].add(Wod.fromMap(wod));
      } else {
        _calendarWodsLocal[date] = [Wod.fromMap(wod)];
      }
    }
    return _calendarWodsLocal;
  }

  Future handleClick(String value) async {
    switch (value) {
      case 'Logout':
        await _auth.signOut();
        break;
      case 'Settings':
        break;
      case 'Stopwatch':
        Navigator.of(this.context).push(MaterialPageRoute(
            builder: (context) => TimerScreen()));
        break;
      case 'Tabata':
        Navigator.of(this.context).push(MaterialPageRoute(
            builder: (context) => TabataScreen()));
        break;
      case 'Search':
        break;
    }
  }
}