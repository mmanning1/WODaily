import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:WODaily/model/wodclass.dart';
import 'package:WODaily/utils/db_helper_util.dart';

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
                          contentPadding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
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
                      value: dropdownValue,
                      items: ['Select One','AMRAP','EMOM','For time','For weight','Chipper','Ladder','Tabata'].map((String value) {
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
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
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
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(10, 15, 20, 15),
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
                                padding: const EdgeInsets.all(15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                elevation: 5,
                                color: Colors.blue.shade900,
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                elevation: 5,
                                color: Colors.blue.shade900,
                                //color: Colors.teal.shade900,
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
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

  }

  void _save(int wodId,String date, String type, String desc, String score) async {
    Wod newWod = Wod(date, type, desc, score);
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
