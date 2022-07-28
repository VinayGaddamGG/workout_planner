// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'MongoDBModel.dart';
import 'constant.dart';

class MongoDatabase {
  static var db, userCollection;

  static connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);

    userCollection = db.collection(USER_COLLECTION);
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final arrData = await userCollection.find().toList();
    return arrData;
  }

  static delete(MongoDbModel user) async {
    await userCollection.remove(where.id(user.id));
  }

  static Future<void> update(MongoDbModel data) async {
    var user = await userCollection.findOne({"_id": data.id});
    user['title'] = data.title;
    user['count'] = data.count;
    user['reps'] = data.reps;
    user['isChecked'] = data.isChecked;

    var saved = await userCollection.save(user);
    inspect(saved);
  }

  static Future<String> insert(MongoDbModel data) async {
    try {
      var user = await userCollection.insertOne(data.toJson());
      if (user.isSuccess) {
        return "Data inserted";
      } else {
        return "Something Wrong while inserting Data";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
