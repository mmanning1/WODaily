import 'package:WODaily/model/workout.dart';
import 'package:WODaily/services/database.dart';
import 'package:WODaily/shared/constants.dart';
import 'package:WODaily/utils/db_helper_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditWodScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object> workout;

  EditWodScreen({this.workout});

  @override
  _EditWodScreenState createState() => _EditWodScreenState(workout);
}

class _EditWodScreenState extends State<EditWodScreen> {
  QueryDocumentSnapshot<Object> workout;
  String type;
  String desc;
  String score;
  DateTime date;
  String _dropdownValue = 'Select One';

  _EditWodScreenState(this.workout);

  @override
  void initState() {
    super.initState();
    _dateController.text=DateFormat('MM/dd/yy').format(workout['date'].toDate());
    _dropdownValue = workout['type'];
    _descriptionController.text=workout['description'];
    _scoreController.text=workout['score'];
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Need to create database helper
  var db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Edit Workout'),
          backgroundColor: Colors.blue.shade900,
        ),
        body: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Form(
                key: _formKey,
                child: Column(
                    children: <Widget>[
                      //Date
                      const SizedBox(height: 15.0,),
                      TextFormField(
                        autofocus: false,
                        //initialValue: DateFormat('MM/dd/yyyy').format(DateTime.now()),
                        controller: _dateController,
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          // Below line stops keyboard from appearing
                          FocusScope.of(context).requestFocus(FocusNode());
                          // Show Date Picker Here
                          await _selectDate(context);
                          // Needs to be 2012-02-27
                          if (date != null) {
                            _dateController.text = DateFormat('MM/dd/yy').format(date);
                          }
                          //setState(() {});
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please select the date";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _dateController.text = value;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: workoutFormDecoration.copyWith(labelText: 'Date'),
                      ),

                      //Type
                      const SizedBox(height: 15.0,),
                      DropdownButtonFormField(

                        alignment: AlignmentDirectional.center,
                        value: _dropdownValue,
                        items: wodTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _dropdownValue = value;
                          });
                        },
                        decoration: workoutFormDecoration.copyWith(labelText: 'Type'),
                      ),

                      //Description
                      const SizedBox(height: 15.0,),
                      TextFormField(
                        autofocus: false,
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: null,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the description of the workout";
                          }
                        },
                        onSaved: (value) {
                          _descriptionController.text = value;
                        },
                        textInputAction: TextInputAction.newline,
                        decoration: workoutFormDecoration.copyWith(hintText: 'Description'),
                      ),

                      //Score
                      const SizedBox(height: 10.0,),
                      TextFormField(
                        autofocus: false,
                        controller: _scoreController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter your score";
                          }
                        },
                        onSaved: (value) {
                          _scoreController.text = value;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: workoutFormDecoration.copyWith(hintText: 'Score'),
                      ),

                      //Buttons
                      const SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: MaterialButton(
                                  padding: EdgeInsets.all(15),
                                  elevation: 5,
                                  color: Theme.of(context).primaryColor,
                                  child:Text("Update",style: TextStyle(color: Colors.white)) ,
                                  onPressed:(){
                                    DatabaseService().updateWodData(workout.id,
                                        _dateController.text,
                                        _descriptionController.text,
                                        _scoreController.text,
                                        _dropdownValue.toString());
                                    //_update(index,workout);
                                    Navigator.pop(context);
                                  }
                              )
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                              child: MaterialButton(
                                  padding: EdgeInsets.all(15),
                                  elevation: 5,
                                  color: Theme.of(context).primaryColor,
                                  child:Text("Cancel",style: TextStyle(color: Colors.white),) ,
                                  onPressed:(){
                                    Navigator.pop(context);
                                  }
                              )
                          ),
                        ],
                      )
                    ]
                )
            )
        )
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date ?? now,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != date) {
      print('hello $picked');
      setState(() {
        date = picked;
      });
    }
  }

  /*
    Use this method for saving workouts locally
    Otherwise use DatabaseService for cloud functions
   */
  _update(int index,Wod wod) async {
    Wod updated = Wod.fromMap({
      "date":_dateController.text,
      "type":_dropdownValue,
      "description":_descriptionController.text,
      "score":_scoreController.text,
      "id":wod.id
    });
    int savedItemId = await db.updateItem(updated);
    print("Updated wod: " + updated.toString() + "to DB: " + savedItemId.toString());
    Navigator.pop(context, updated);
  }
}