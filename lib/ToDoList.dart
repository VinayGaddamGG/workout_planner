import 'package:flutter/material.dart';

import 'MongoDBModel.dart';
import 'ToDoAdder.dart';
import 'mongodb.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  Future<void> _updateData(
      var id, String title, String description, bool isChecked) async {
    final updateData = MongoDbModel(
        id: id, title: title, description: description, isChecked: isChecked);

    // ignore: unused_local_variable
    var result = await MongoDatabase.update(updateData).whenComplete(() {
      setState(() {});
    });
  }

  bool change = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 25, 25),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ToDoAdder(change: false)));
            },
          ),
        ],
        title: const Text(
          'Your To Do items today',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      body: Center(
        child: FutureBuilder(
            future: MongoDatabase.getData(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return toDoCards(
                            MongoDbModel.fromJson(snapshot.data[index]));
                      });
                } else {
                  return const Center(
                      child: Text('Nothing To Do!',
                          style: TextStyle(color: Colors.white, fontSize: 30)));
                }
              }
            }),
      ),
    ));
  }

  Widget toDoCards(MongoDbModel data) {
    Text title;
    Text description;

    if (data.isChecked == true) {
      description = Text(
        data.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          decoration: TextDecoration.lineThrough,
        ),
      );
    } else {
      description = Text(
        data.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }

    if (data.isChecked == true) {
      title = Text(
        data.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          decoration: TextDecoration.lineThrough,
        ),
      );
    } else {
      title = Text(
        data.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }

    return Card(
      child: Row(
        children: [
          Checkbox(
              value: data.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  data.isChecked = value!;
                  _updateData(
                      data.id, data.title, data.description, data.isChecked);
                });
              }),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 5),
                description,
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                MongoDatabase.delete(data);
                setState(() {});
              },
              icon: const Icon(Icons.close)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) {
                          return ToDoAdder(change: true);
                        },
                        settings: RouteSettings(arguments: data)));
              },
              icon: const Icon(Icons.edit))
        ],
      ),
    );
  }
}
