
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
import 'package:table_calendar/table_calendar.dart';

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
  List<bool> _isSelected = [true, false];
  bool _calendarMode = false;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  Map<DateTime,List<Wod>> _calendarWods;
  DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.sss');

  List<Wod> _getWodsForDay(DateTime date){
    date = DateTime.parse(_dateFormat.format(date));
    return _calendarWods[date] ?? [];
  }

  @override
  void initState(){
    _calendarWods = {};
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
                children: [
                  Expanded(
                    child: ToggleButtons(
                      constraints: BoxConstraints(
                        minWidth: (MediaQuery.of(context).size.width -3) / 2,
                        minHeight: 40.0,
                      ),
                      children: [
                        Icon(FontAwesomeIcons.listUl),
                        Icon(FontAwesomeIcons.calendar),
                      ],
                      isSelected: _isSelected,
                      onPressed: (int index) {
                        setState(() {
                          print('Button selected: ' + index.toString());
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
              _calendarMode ? getCalenderView() : getListView(),
            ],
          ),
        ),
        floatingActionButton: _calendarMode ? null : FloatingActionButton(
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

  Widget getCalenderView(){
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

          eventLoader: (day) {
            return _getWodsForDay(day);
          },

          // Header format
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false
          ),

          // Calendar Style
          calendarStyle: CalendarStyle(
            isTodayHighlighted: true,
            selectedTextStyle: TextStyle(color: Colors.white),

            defaultDecoration: BoxDecoration(
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

          // Day selected
          onDaySelected: (DateTime selectDay, DateTime focusDay){
            setState(() {
              selectedDay = selectDay;
              focusedDay = focusDay;
            });
            print(focusedDay);
          },
          selectedDayPredicate: (DateTime date){
            return isSameDay(selectedDay,date);
          },
        ),
        ..._getWodsForDay(selectedDay).map((Wod wod) => Card(
          elevation: 5,
          margin: EdgeInsets.all(3),
          shape:const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          child: ListTile(
              title: Text(DateFormat('MM/dd/yy').format(DateTime.parse(wod.date))),
              subtitle: Text(wod.type + ":" + wod.description, style: const TextStyle(fontSize: 16.0),),
              trailing: Text(wod.score),
            ),
        ),
        )
      ]
    );
  }

  Widget getListView(){
    return Expanded(
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
        ]
      ),
    );
  }

  getData() async {
    // Will have to incorporate year here eventually to
    // prevent past years data from populating into current year
    _wodList.clear();
    print('Getting data for month: $_month');
    List wods = await db.getMonthData(_month);
    for (var wod in wods) {
      setState(() {
        _wodList.add(Wod.fromMap(wod));

        DateTime date = DateTime.parse(Wod.fromMap(wod).date);
        print("Date from wods: " + date.toLocal().toString());
        if (_calendarWods[date]!=null) {
          _calendarWods[date].add(Wod.fromMap(wod));
        } else {
          _calendarWods[date] = [Wod.fromMap(wod)];
        }
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