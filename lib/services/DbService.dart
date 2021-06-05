import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plannus/models/Event.dart';

class DbService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference events = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("events");

  Future<String> getUserProfilePic() async {
    try {
      User currentUser = _auth.currentUser;
      DocumentSnapshot snapshot =
          await _db.collection("users").doc(currentUser.uid).get();
      return snapshot["profilePic"];
    } catch (error) {
      print(error); // TODO: remove temp debug
      return null;
    }
  }

  Future<String> getUsername() async {
    try {
      User currentUser = _auth.currentUser;
      DocumentSnapshot snapshot =
          await _db.collection("users").doc(currentUser.uid).get();
      return snapshot["username"];
    } catch (error) {
      print(error); // TODO: remove temp debug
      return null;
    }
  }

  Future<String> getEmail() async {
    try {
      User currentUser = _auth.currentUser;
      DocumentSnapshot snapshot =
          await _db.collection("users").doc(currentUser.uid).get();
      return snapshot["email"];
    } catch (error) {
      print(error); // TODO: remove temp debug
      return null;
    }
  }

  Future addNewEvent(Event event) async {
    return await events.add(event.toMap());
  }

  List<Event> _eventListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Event(
        id: doc.id ?? 1,
        completed: doc.get("completed") ?? false,
        passed: doc.get("passed") ?? false,
        category: doc.get("category") ?? '',
        description: doc.get("description") ?? '',
        startTime: DateTime.parse(doc.get("startTime").toDate().toString()) ??
            DateTime.now(),
        endTime: DateTime.parse(doc.get("endTime").toDate().toString()) ??
            DateTime.now(),
      );
    }).toList();
  }

  Stream<List<Event>> get eventsStream {
    return events.snapshots().map(_eventListFromSnapshot);
  }

  Future markCompleted(Event event) async {
    DocumentReference temp = events.doc(event.id);
    return await temp.update({
      "passed": true,
      "completed": true,
    });
  }

  Future markUncompleted(Event event) async {
    DocumentReference temp = events.doc(event.id);
    return await temp.update({
      "passed": true,
      "completed": false,
    });
  }

  Future editEvent(Event old, Event change) async {
    return await events.doc(old.id).set({
      "category": change.category,
      "description": change.description,
      "startTime": change.startTime,
      "endTime": change.endTime,
      "completed": false,
      "passed": false,
    });
  }

  void delete(Event event) async {
    return await events.doc(event.id).delete();
  }

  Future<int> countCompletedEventByCategory(String category) async {
    User currentUser = _auth.currentUser;
    DocumentSnapshot snapshot = await _db
        .collection("users")
        .doc(currentUser.uid)
        .collection("stats")
        .doc(category)
        .get();

    return snapshot.get("value");
  }

  Future<Map<String, int>> getAllCompletedEventCount() async {
    return {
      "total": await countCompletedEventByCategory("total"),
      "Studies": await countCompletedEventByCategory("Studies"),
      "Fitness": await countCompletedEventByCategory("Fitness"),
      "Arts": await countCompletedEventByCategory("Arts"),
      "Social": await countCompletedEventByCategory("Social"),
      "Others": await countCompletedEventByCategory("Others"),
    };
  }

  Future<int> getUserLevel() async {
    User currentUser = _auth.currentUser;
    DocumentSnapshot snapshot = await _db
        .collection("users")
        .doc(currentUser.uid)
        .collection("stats")
        .doc("level")
        .get();
    return snapshot.get("value");
  }

  Future<int> getUserCurrentExp() async {
    User currentUser = _auth.currentUser;
    DocumentSnapshot snapshot = await _db
        .collection("users")
        .doc(currentUser.uid)
        .collection("stats")
        .doc("level")
        .get();
    return snapshot.get("exp");
  }

  Future<int> getUserNextExp() async {
    User currentUser = _auth.currentUser;
    DocumentSnapshot snapshot = await _db
        .collection("users")
        .doc(currentUser.uid)
        .collection("stats")
        .doc("level")
        .get();
    return snapshot.get("next");
  }

  Future<bool> isUserStatsEmpty() async {
    User currentUser = _auth.currentUser;
    QuerySnapshot snapshot = await _db
        .collection("users")
        .doc(currentUser.uid)
        .collection("stats")
        .get();

    List docs = snapshot.docs;

    return docs.isEmpty;
  }

  /// Use for initialising new user/existing user stats
  Future<void> initUserStats() async {
    User currentUser = _auth.currentUser;
    CollectionReference stats =
        _db.collection("users").doc(currentUser.uid).collection("stats");

    stats.doc("level").set({
      "category": "level",
      "value": 0,
      "exp": 0,
      "next": 100, // exp required for level 1. can be adjusted.
    });

    List<String> categories = [
      "total",
      "Studies",
      "Fitness",
      "Arts",
      "Social",
      "Others"
    ];

    categories.forEach((element) {
      stats.doc(element).set({
        "category": element,
        "value": 0,
      });
    });
  }

  // TODO: Remove helper method
  /// Sync user stats from event collection.
  /// This should only be called for existing users
  /// & used for debugging purposes.
  Future<void> syncUserStats() async {
    Map<String, int> allEventCount = await getAllCompletedEventCount();
    CollectionReference stats =
        _db.collection("users").doc(currentUser.uid).collection("stats");
    allEventCount.forEach((key, value) {
      stats.doc(key).update({
        "category": key,
        "value": value,
      }).then((_) {
        print(key + ": " + value.toString()); // TODO: remove temp debugging
      });
    });
  }
}
