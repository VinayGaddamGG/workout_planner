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
      required this.description,
      required this.isChecked});

  ObjectId id;
  String title;
  String description;
  bool isChecked;

  factory MongoDbModel.fromJson(Map<String, dynamic> json) => MongoDbModel(
      id: json["_id"],
      title: json["title"],
      description: json["description"],
      isChecked: json["isChecked"]);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "isChecked": isChecked,
      };
}
