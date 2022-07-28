// To parse this JSON data, do
//
//     final mongoDbModel = mongoDbModelFromJson(jsonString);

import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

MongoDbModel mongoDbModelFromJson(String str) =>
    MongoDbModel.fromJson(json.decode(str));

String mongoDbModelToJson(MongoDbModel data) => json.encode(data.toJson());

class MongoDbModel {
  MongoDbModel(
      {required this.id,
      required this.title,
      required this.count,
      required this.reps,
      required this.isChecked});

  ObjectId id;
  String title;
  int count;
  int reps;
  bool isChecked;

  factory MongoDbModel.fromJson(Map<String, dynamic> json) => MongoDbModel(
      id: json["_id"],
      title: json["title"],
      count: json["count"],
      reps: json["reps"],
      isChecked: json["isChecked"]);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "count": count,
        "reps": reps,
        "isChecked": isChecked,
      };
}
