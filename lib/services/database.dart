import 'package:WODaily/model/workout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  //collection ref
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String last, String first) async {
    return await users.doc(uid).set({
      'firstName': first,
      'lastName': last
    });
  }

  /*
  List<Wod> _wodListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Wod(
        doc.data['date'] ?? '',
        doc.data['type'] ?? '',
        doc.data['description'] ?? '',
        doc.data['score'] ?? ''
      );
    }).toList();
  }

  //get users stream
  Stream<List<Wod>> get dbusers {
    return wods.snapshots().map(_wodListFromSnapshot);
  }
   */

  //get users stream
  Stream<QuerySnapshot> get dbusers {
    return users.snapshots();
  }

  //need to update wods from here

  //need a stream for wods for home to access

}