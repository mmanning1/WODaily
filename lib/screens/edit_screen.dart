import 'package:WODaily/model/wodclass.dart';
import 'package:WODaily/utils/db_helper_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditWodScreen extends StatefulWidget {
  final Wod workout;
  final int index;

  EditWodScreen({this.workout, this.index});

  @override
  _EditWodScreenState createState() => _EditWodScreenState(workout,index);
}

class _EditWodScreenState extends State<EditWodScreen> {
  Wod workout;
  int index;
  int id;
  String type;
  String desc;
  String score;
  DateTime date;
  String _dropdownValue = 'Select One';

  _EditWodScreenState(this.workout,this.index);

  @override
  void initState() {
    super.initState();
    id=workout.id;
    _dateController.text=workout.date;
    _dropdownValue = workout.type;
    _descriptionController.text=workout.description;
    _scoreController.text=workout.score;
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
          title: const Text('New Workout'),
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
                          _dateController.text = DateFormat('yyyy-MM-dd').format(date);
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
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 15, 20, 15),
                            hintText: "Date",
                            labelText: "Date",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),

                      //Type
                      const SizedBox(height: 15.0,),
                      DropdownButtonFormField(

                        alignment: AlignmentDirectional.center,
                        value: _dropdownValue,
                        items: ['Select One','AMRAP','EMOM','For time','For weight','Chipper','Ladder','Tabata'].map((String value) {
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
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
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
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 15, 20, 15),
                            hintText: "Description",
                            labelText: "Description",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
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
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            hintText: "Score",
                            labelText: "Score",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),

                      //Buttons
                      const SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: MaterialButton(
                                  padding: EdgeInsets.all(15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 5,
                                  color: Colors.blue.shade900,
                                  child:Text("Update",style: TextStyle(color: Colors.white)) ,
                                  onPressed:(){
                                    _update(index,workout);

                                  }
                              )
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                              child: MaterialButton(
                                  padding: EdgeInsets.all(15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  elevation: 5,
                                  color: Colors.blue.shade900,
                                  //color: Colors.teal.shade900,
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
        firstDate: now,
        lastDate: DateTime(2101));
    if (picked != null && picked != date) {
      print('hello $picked');
      setState(() {
        date = picked;
      });
    }
  }

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