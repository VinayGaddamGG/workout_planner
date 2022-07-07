import 'package:flutter/material.dart';

import 'MongoDBModel.dart';
import 'ToDoList.dart';
import 'mongodb.dart';
// ignore: library_prefixes
import 'package:mongo_dart/mongo_dart.dart' as M;

// ignore: must_be_immutable
class ToDoAdder extends StatefulWidget {
  bool change;
  //MongoDatabase data;
  ToDoAdder(
      {required this.change,
      //required this.data
      Key? key})
      : super(key: key);

  @override
  State<ToDoAdder> createState() => _ToDoAdderState();
}

class _ToDoAdderState extends State<ToDoAdder> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  var _insertOrUpdate = "Add To Do";

  @override
  Widget build(BuildContext context) {
    MongoDbModel? data =
        ModalRoute.of(context)!.settings.arguments as MongoDbModel?;

    // ignore: unnecessary_null_comparison
    if (data != null) {
      _title.text = data.title;
      _description.text = data.description;
      _insertOrUpdate = "Update To Do";
    } else {
      _title.text = '';
      _description.text = '';
      _insertOrUpdate = "Add To Do";
    }

    Future<void> _insertData(String title, String description) async {
      // ignore: no_leading_underscores_for_local_identifiers
      var _id = M.ObjectId();
      bool isChecked = false;
      final data = MongoDbModel(
          id: _id,
          title: title,
          description: description,
          isChecked: isChecked);
      // ignore: unused_local_variable
      var result = await MongoDatabase.insert(data);
    }

    Future<void> _updateData(
        var id, String title, String description, bool isChecked) async {
      final updateData = MongoDbModel(
          id: id, title: title, description: description, isChecked: isChecked);
      _title.text = '';
      _description.text = '';

      // ignore: unused_local_variable
      var result = await MongoDatabase.update(updateData).then((value) =>
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ToDoList()))
              .then((value) {
            setState(() {});
          }));
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 36, 35, 35),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 36, 35, 35),
          title: const Text("Create a To Do",
              style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                style: const TextStyle(color: Colors.white, fontSize: 20),
                controller: _title,
                decoration: const InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white, fontSize: 20),
                controller: _description,
                decoration: const InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        if (widget.change == false) {
                          _insertData(_title.text, _description.text);
                          _title.text = '';
                          _description.text = '';
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ToDoList()))
                              .then((value) {
                            setState(() {});
                          });
                        } else {
                          _updateData(data!.id, _title.text, _description.text,
                              data.isChecked);
                        }
                      },
                      child: Text(_insertOrUpdate,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20))),
                ],
              )
            ],
          ),
        )));
  }
}
