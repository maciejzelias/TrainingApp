import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:training_app/widgets/exercise_Card.dart';

class ChooseExercisesDialog extends StatefulWidget {
  late final List exercises;
  ChooseExercisesDialog(List exercises) {
    this.exercises = exercises;
  }

  @override
  State<ChooseExercisesDialog> createState() =>
      _ChooseExercisesDialogState(exercises);
}

class _ChooseExercisesDialogState extends State<ChooseExercisesDialog> {
  late List exercises;
  bool isFetched = false;
  late List<Map> documents = [];
  late String id;

  _ChooseExercisesDialogState(List exercises) {
    this.exercises = exercises;
    this.id = FirebaseAuth.instance.currentUser!.uid;
    fetchData();
  }

  void fetchData() async {
    this.documents.clear();
    var stream1 = await FirebaseFirestore.instance
        .collection('exercises/$_group/excersises')
        .get();
    var stream2 = await FirebaseFirestore.instance
        .collection('users/$id/exercises/$_group/exercises')
        .get();

    stream1.docs.forEach((element) {
      this.documents.add(element.data());
    });

    stream2.docs.forEach((element) {
      this.documents.add(element.data());
    });

    this.documents.sort(((a, b) => a['name'].compareTo(b['name'])));
    setState(() {
      isFetched = true;
    });
  }

  String type = 'Chest';
  String _group = 'chest';
  final List<String> gropus = [
    'Back',
    'Chest',
    'Legs',
    'Shoulders',
    'Core',
    'Arms'
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type,
                  style: TextStyle(fontSize: 50),
                ),
                DropdownButton(
                    value: type,
                    items: gropus.map((String group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        type = newValue!;
                        _group = type.toLowerCase();
                        fetchData();
                      });
                    })
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: ((context, index) {
                    return ExerciseCard(exercises, documents[index], _group);
                  })),
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context, true);
                },
                child: Text('Add exercises'))
          ],
        ),
      ),
    );
  }
}
