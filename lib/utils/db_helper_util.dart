import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:WODaily/model/workout.dart';


class DatabaseHelper {
  static Database  _db;
  final String tableName = "wod";
  final String columnId = "id";
  final String columnDate = "date";
  final String columnType= "type";
  final String columnDescription= "description";
  final String columnScore= "score";

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDB();

    return _db;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "wod_daily.db");
    var ourDB = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDB;
  }


  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnDate TEXT, $columnType TEXT, $columnDescription TEXT, $columnScore TEXT)");
  }

  insertData(Wod noDoItem) async {
    var dbClient = await db;
    int result = await dbClient.insert("$tableName", noDoItem.toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
    return result;
  }

  getSingleData(int savedItemId) async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery("SELECT * FROM $tableName WHERE $columnId = $savedItemId");

    if (result.length == 0) return null;
    return Wod.fromMap(result.first);
  }

  Future<int> updateItem(Wod updatedWod) async {
    var dbClient = await db;
    print("Updating wod with id: " + updatedWod.id.toString());
    return await dbClient.update(tableName, updatedWod.toMap(),
        where: "$columnId =?", whereArgs: [updatedWod.id]);
  }

  // Get Items
  // TODO: add date to this call
  Future<List> getAllData() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ORDER BY $columnDate DESC");
    return result.toList();
  }

  Future<List> getMonthData(int month) async {
    var dbClient = await db;
    String monthStr = month.toString().padLeft(2,'0');
    String currYear = DateTime.now().year.toString();
    var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE strftime('%m', $columnDate) = '$monthStr' ORDER BY $columnDate DESC");
    //var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE strftime('%m', $columnDate) = '$monthStr' AND strftime('%Y', $columnDate) = '$currYear'");
    return result.toList();
  }

  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }
}