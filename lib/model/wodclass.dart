/// See https://docs.flutter.dev/cookbook/persistence/sqlite for doc

class Wod {
  //String _title;
  int _id;
  String _date;
  String _type;
  String _description;
  String _score;


  Wod(this._date, this._type, this._description, this._score);

  //String get title => _title;
  int get id=>_id;
  String get date => _date;
  String get type => _type;
  String get description => _description;
  String get score => _score;


  Map<String, dynamic>toMap(){
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
    this._date=map["date"];
    this._type=map["type"];
    this._description=map["description"];
    this._score=map["score"];
    this._id=map["id"];
  }
}