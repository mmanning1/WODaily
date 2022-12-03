import 'package:WODaily/model/user.dart';
import 'package:WODaily/services/auth.dart';
import 'package:WODaily/services/database.dart';
import 'package:WODaily/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:WODaily/model/workout.dart';
import 'package:WODaily/utils/db_helper_util.dart';
import 'package:provider/provider.dart';


class EnterWodScreen extends StatefulWidget {
  int id;
  Wod wod;
  DateTime date;
  String type;
  String desc;
  String score;

  @override
  _EnterWodScreenState createState() => _EnterWodScreenState();
}

class _EnterWodScreenState extends State<EnterWodScreen>{
  int id;
  String type;
  String desc;
  String score;
  DateTime date;
  String dropdownValue = 'Select One';

  final List<Wod> _wod = <Wod>[];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Need to create database helper - might not need this after fiebase
  var db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('New Workout'),
        ),
        body: Container(
          child: Padding(
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
                      value: dropdownValue,
                      items: wodTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dropdownValue = value;
                        });
                      },
                        decoration: workoutFormDecoration.copyWith(labelText: 'Type'),
                    ),

                    //Description
                    SizedBox(height: 15.0,),
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
                                padding: const EdgeInsets.all(15),
                                elevation: 5,
                                color: Theme.of(context).primaryColor,
                                child:Text("Save",style: TextStyle(color: Colors.white)) ,
                                onPressed:(){
                                  _save(id,_dateController.text,dropdownValue,_descriptionController.text,_scoreController.text);
                                }
                            )
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                            child: MaterialButton(
                                padding: EdgeInsets.all(15),
                                elevation: 5,
                                color: Theme.of(context).primaryColor,
                                child:const Text("Cancel",style: TextStyle(color: Colors.white),) ,
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
        )
    );
  }

  @override
  void initState() {
    super.initState();
    print('Creating new WOD');
    _dateController.text = DateFormat('MM/dd/yy').format(DateTime.now());

  }

  void _save(int wodId,String date, String type, String desc, String score) async {
    final user = Provider.of<WodUser>(context, listen: false);
    Wod newWod = Wod(date: date, type: type, description: desc, score: score);

    //firebase
    await DatabaseService().createWodData(newWod, user.uid);

    //internal db
    int savedItemId = await db.insertData(newWod);
    // Don't need this now, might implement later
    //Wod addedItem = await db.getSingleData(savedItemId);
    print("Saved wod: " + newWod.toString() + " to DB: " + savedItemId.toString());
    Navigator.pop(context, newWod);
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
}
