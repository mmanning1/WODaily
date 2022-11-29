import 'package:WODaily/model/workout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  //collection ref
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final CollectionReference wods = FirebaseFirestore.instance.collection('workouts');

  Future updateUserData(String last, String first) async {
    return await users.doc(uid).set({
      'firstName': first,
      'lastName': last
    });
  }

  //get users stream
  Stream<QuerySnapshot> get dbusers {
    return users.snapshots();
  }

  Stream<QuerySnapshot> get dbwods {
    // Only get from this month
    return wods.where('month',isEqualTo: DateFormat('MMMM').format(DateTime(0, DateTime.now().month))).snapshots();
  }

  Stream<QuerySnapshot> dbwodsByMonth(int month) {
    // Only get from this month
    int year = DateTime.now().year;
    print('Getting wods by month: ' + DateFormat('MMMM').format(DateTime(0, month)));
    Stream<QuerySnapshot> stream = wods.where('month',isEqualTo: DateFormat('MMMM').format(DateTime(0, month))).snapshots();

    return stream;
  }

  //need to create or update wods from here
  Future createWodData(Wod wod) async {
    print("New wod: " + wod.toString());
    final DocumentReference dr = await wods.add(wod.toFirestoreMap());
    return dr.id;
  }

  void deleteWod(String id) {
    wods.doc(id).delete()
        .then((value) => print("Delete successul!"));
  }

  Future updateWodData(String uid, String date, String desc, String score, String type) async {
    DateTime dttm = DateFormat('MM/dd/yy').parse(date);
    String month = DateFormat('MMMM').format(DateTime(0, dttm.month));
    return await wods.doc(uid).set({
      'date': dttm,
      'month':month,
      'description': desc,
      'score': score,
      'type': type,
    }).then((value) => print("Update successful!"));
  }

}