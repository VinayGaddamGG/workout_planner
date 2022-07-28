import 'package:flutter/material.dart';

import 'MongoDBModel.dart';
import 'mongodb.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'package:numberpicker/numberpicker.dart';

class WorkOutList extends StatefulWidget {
  const WorkOutList({Key? key}) : super(key: key);

  @override
  State<WorkOutList> createState() => _WorkOutListState();
}

class _WorkOutListState extends State<WorkOutList> {
  int currentValueReps = 0;
  int currentValueCount = 0;

  TextEditingController workoutName = TextEditingController();

  Future<void> _updateData(
      var id, String title, int count, int reps, bool isChecked) async {
    final updateData = MongoDbModel(
        id: id, title: title, count: count, reps: reps, isChecked: isChecked);

    // ignore: unused_local_variable
    var result = await MongoDatabase.update(updateData);
  }

  Future<void> _insertData(String title, int count, int reps) async {
    // ignore: no_leading_underscores_for_local_identifiers
    var _id = M.ObjectId();
    bool isChecked = false;
    final data = MongoDbModel(
        id: _id,
        title: title,
        count: currentValueCount,
        reps: currentValueReps,
        isChecked: isChecked);
    // ignore: unused_local_variable
    var result = await MongoDatabase.insert(data).then((value) {
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
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              MongoDbModel? data =
                  ModalRoute.of(context)!.settings.arguments as MongoDbModel?;

              // ignore: unnecessary_null_comparison

              workoutName.text = '';
              currentValueReps = 0;
              currentValueCount = 0;

              showDialog<int>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        backgroundColor: Color.fromARGB(255, 25, 25, 25),
                        title: const Text(
                          'Add a workout',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        content: StatefulBuilder(
                          // ignore: non_constant_identifier_names
                          builder: (context, SBsetState) {
                            return Expanded(
                              child: Column(
                                children: [
                                  Padding(padding: EdgeInsets.only(top: 20)),
                                  TextFormField(
                                    controller: workoutName,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 19),
                                    decoration: const InputDecoration(
                                        labelText: 'Workout Name',
                                        labelStyle: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                        icon: Icon(
                                          Icons.fitness_center,
                                        )),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 70)),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Enter Sets:",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                          )),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(right: 2),
                                          child: Text(
                                            "Enter Reps:",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      NumberPicker(
                                          value: currentValueCount,
                                          minValue: 0,
                                          maxValue: 100,
                                          onChanged: (newValue) {
                                            SBsetState(() =>
                                                currentValueCount = newValue);
                                          }),
                                      NumberPicker(
                                          value: currentValueReps,
                                          minValue: 0,
                                          maxValue: 100,
                                          onChanged: (newValue) {
                                            SBsetState(() =>
                                                currentValueReps = newValue);
                                          })
                                    ],
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        _insertData(
                                            workoutName.text,
                                            currentValueCount,
                                            currentValueReps);
                                        workoutName.text = '';
                                        currentValueCount = 0;
                                        currentValueReps = 0;
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const WorkOutList()))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: const Text("Create Workout",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20))),
                                ],
                              ),
                            );
                          },
                        ));
                  });
            },
          ),
        ],
        title: const Text(
          'Your Workouts for Today',
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

    if (data.isChecked == true) {
      title = Text(
        "${data.title}" "${data.count}x${data.reps}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 23,
          decoration: TextDecoration.lineThrough,
        ),
      );
    } else {
      title = Text(
        "${data.title} " "${data.count}x${data.reps}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 23,
        ),
      );
    }

    return Card(
      child: Row(
        children: [
          Checkbox(
              value: data.isChecked,
              onChanged: (bool? value) {
                data.isChecked = value!;

                _updateData(data.id, data.title, data.count, data.reps,
                        data.isChecked)
                    .whenComplete(() {
                  setState(() {});
                });
              }),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title,
                const SizedBox(height: 5),
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
                workoutName.text = data.title;
                currentValueCount = data.count;
                currentValueReps = data.reps;

                showDialog<int>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          backgroundColor: Color.fromARGB(255, 25, 25, 25),
                          title: const Text(
                            'Update a workout',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                          content: StatefulBuilder(
                            // ignore: non_constant_identifier_names
                            builder: (context, SBsetState) {
                              return Expanded(
                                child: Column(
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.only(top: 20)),
                                    TextFormField(
                                      controller: workoutName,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 19),
                                      decoration: const InputDecoration(
                                          labelText: 'Workout Name',
                                          labelStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                          icon: Icon(
                                            Icons.fitness_center,
                                          )),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(bottom: 70)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "Enter Sets:",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            )),
                                        Padding(
                                            padding: EdgeInsets.only(right: 2),
                                            child: Text(
                                              "Enter Reps:",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        NumberPicker(
                                            value: currentValueCount,
                                            minValue: 0,
                                            maxValue: 100,
                                            onChanged: (newValue) {
                                              SBsetState(() =>
                                                  currentValueCount = newValue);
                                            }),
                                        NumberPicker(
                                            value: currentValueReps,
                                            minValue: 0,
                                            maxValue: 100,
                                            onChanged: (newValue) {
                                              SBsetState(() =>
                                                  currentValueReps = newValue);
                                            })
                                      ],
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          _updateData(
                                                  data.id,
                                                  workoutName.text,
                                                  currentValueCount,
                                                  currentValueReps,
                                                  data.isChecked)
                                              .whenComplete(() =>
                                                  Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const WorkOutList()))
                                                      .whenComplete(() {
                                                    setState(() {});
                                                  }));
                                        },
                                        child: const Text("Update Workout",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20)))
                                  ],
                                ),
                              );
                            },
                          ));
                    });
              },
              icon: const Icon(Icons.edit))
        ],
      ),
    );
  }
}
