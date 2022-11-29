import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// See https://docs.flutter.dev/cookbook/persistence/sqlite for doc

class Wod {
  //String _title;
  int id;
  String date;
  String type;
  String description;
  String score;


  Wod({this.date, this.type, this.description, this.score});

  //String get title => _title;
  int get _id=>id;
  String get _date => date;
  String get _type => type;
  String get _description => description;
  String get _score => score;


  Map<String, dynamic>toFirestoreMap(){
    DateTime dttm = DateFormat('MM/dd/yy').parse(date);
    String month = DateFormat('MMMM').format(DateTime(0, dttm.month));
    return {
      'date' : dttm,
      'month' : month,
      'type' : type,
      'description' : description,
      'score' : score
    };
  }

  Map<String, dynamic>toSQliteMap(){
    return {
      'id' : id,
      'date' : date,
      'type' : type,
      'description' : description,
      'score' : score
    };
  }

  @override
  String toString(){
    return 'Wod{id: $id, date: $date, type: $type, description: $description, score: $score}';
  }

  Wod.fromMap(Map<String,dynamic>map){
    //this._title=map["title"];
    this.date=map["date"];
    this.type=map["type"];
    this.description=map["description"];
    this.score=map["score"];
    this.id=map["id"];
  }
}