
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:training_app/widgets/choose_exercises_dialog.dart';
import 'package:training_app/widgets/exercise_in_Training.dart' show typeOfExercise;

class EditTemplateScreen extends StatefulWidget {
  final DocumentReference document;
  final String title;

  EditTemplateScreen(this.document, this.title);

  @override
  State<EditTemplateScreen> createState() =>
      _EditTemplateScreenState(document, title);
}

class _EditTemplateScreenState extends State<EditTemplateScreen> {
  bool _isLoading = true;
  DocumentReference template;
  String title;
  late String id;
  late String docId;
  late List<Map<String, dynamic>> exercises;
  late final List<dynamic> copyOfExercises;
  late List<QueryDocumentSnapshot<Object?>> exercisesTemplate;

  _EditTemplateScreenState(this.template, this.title) {
    this.id = FirebaseAuth.instance.currentUser!.uid;
    _fetchData();
    this.docId = template.id;
  }

  void _fetchData() async {
    var ex = await template
        .collection('exercises')
        .orderBy('sortingNumber', descending: false)
        .get();
    exercisesTemplate = ex.docs;
    exercises = ex.docs.map((doc) => doc.data()).toList();
    copyOfExercises = exercises.toList();
    print(exercises);
    setState(() {
      _isLoading = false;
    });
  }

  void reNewSortingNumbers() {
    for (int i = 0; i < exercises.length; i++)
      exercises[i]['sortingNumber'] = i;
  }

  void trySubmit() async {
    await FirebaseFirestore.instance
        .collection('users/$id/templates')
        .doc(docId)
        .set({
      'title': title,
    });
    for (int i = 0; i < copyOfExercises.length; i++) {
      if (copyOfExercises.elementAt(i)['numberOfSets'] != 0) {
        exercisesTemplate.elementAt(i).reference.update({
          'numberOfSets': copyOfExercises[i]['numberOfSets'],
          'sortingNumber': copyOfExercises[i]['sortingNumber'],
          'lastTraining': copyOfExercises[i]['lastTraining']
        });
      } else {
        exercisesTemplate.elementAt(i).reference.delete();
      }
      exercises.remove(copyOfExercises.elementAt(i));
    }

    var doc = template as DocumentReference<Map<String, dynamic>>;

    exercises.forEach((element) {
      doc.collection('exercises').add({
        'part': element['part'],
        'name': element['name'],
        'type': element['type'],
        'numberOfSets': element['numberOfSets'],
        'lastTraining': element['lastTraining'],
        'sortingNumber': element['sortingNumber'],
      });
    });
  }

  List<Map<String, dynamic>> exercisesToAdd = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Edit your template')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  ReorderableListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      onReorder: ((oldIndex, newIndex) {
                        setState(() {
                          var pomoc = exercises[oldIndex];
                          if (oldIndex > newIndex) {
                            for (int i = oldIndex; i > newIndex; i--) {
                              print('chuj');
                              exercises[i] = exercises[i - 1];
                            }
                            exercises[newIndex] = pomoc;
                          } else {
                            for (int i = oldIndex; i < newIndex - 1; i++) {
                              exercises[i] = exercises[i + 1];
                            }
                            exercises[newIndex - 1] = pomoc;
                          }
                          reNewSortingNumbers();
                          print(exercises);
                        });
                      }),
                      shrinkWrap: true,
                      itemCount: exercises.length,
                      itemBuilder: ((context, index) {
                        late typeOfExercise type;
                        switch (exercises[index]['type']) {
                          case 'weight':
                            type = typeOfExercise.weight;
                            break;
                          case 'bodyweight+':
                            type = typeOfExercise.bodyweightPlus;
                            break;
                          case 'bodyweight':
                            type = typeOfExercise.bodyweight;
                            break;
                          case 'time':
                            type = typeOfExercise.time;
                            break;
                        }
                        int _numberOfSets = exercises[index]['numberOfSets'];
                        return Container(
                          key: ValueKey(exercises[index]['sortingNumber']),
                          child: Card(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      exercises[index]['name'],
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            exercises.elementAt(
                                                index)['numberOfSets'] = 0;
                                            exercises.remove(exercises[index]);
                                            reNewSortingNumbers();
                                            print(exercises);
                                          });
                                        },
                                        icon: Icon(Icons.delete))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Sets : '),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_numberOfSets > 1) {
                                              _numberOfSets--;
                                              exercises[index]['numberOfSets'] =
                                                  _numberOfSets;
                                              exercises[index]['lastTraining']
                                                  .remove((_numberOfSets + 1)
                                                      .toString());
                                              reNewSortingNumbers();
                                              print(exercises);
                                            }
                                          });
                                        },
                                        icon: Icon(Icons.remove)),
                                    Text(_numberOfSets.toString()),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _numberOfSets++;
                                            exercises[index]['numberOfSets'] =
                                                _numberOfSets;

                                            switch (type) {
                                              case typeOfExercise.weight:
                                                exercises[index]['lastTraining']
                                                    .addAll({
                                                  exercises[index]
                                                          ['numberOfSets']
                                                      .toString(): [0, 0]
                                                });
                                                break;
                                              case typeOfExercise
                                                  .bodyweightPlus:
                                                exercises[index]['lastTraining']
                                                    .addAll({
                                                  exercises[index]
                                                          ['numberOfSets']
                                                      .toString(): [0, 0]
                                                });
                                                break;
                                              case typeOfExercise.time:
                                                exercises[index]['lastTraining']
                                                    .addAll({
                                                  exercises[index]
                                                          ['numberOfSets']
                                                      .toString(): [0]
                                                });
                                                break;
                                              case typeOfExercise.bodyweight:
                                                exercises[index]['lastTraining']
                                                    .addAll({
                                                  exercises[index]
                                                          ['numberOfSets']
                                                      .toString(): [0]
                                                });
                                                break;
                                            }
                                          });
                                        },
                                        icon: Icon(Icons.add))
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      })),
                  ElevatedButton(
                      onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      ChooseExercisesDialog(exercisesToAdd))
                              .then((value) {
                            setState(() {
                              for (int i = 0; i < exercisesToAdd.length; i++) {
                                exercisesToAdd[i]['lastTraining'] =
                                    new Map<String, dynamic>();
                                switch (exercisesToAdd[i]['type']) {
                                  case 'weight':
                                    exercisesToAdd[i]['lastTraining'].addAll({
                                      '1': [0, 0]
                                    });
                                    break;
                                  case 'bodyweight+':
                                    exercisesToAdd[i]['lastTraining'].addAll({
                                      '1': [0, 0]
                                    });
                                    break;
                                  case 'time':
                                    exercisesToAdd[i]['lastTraining'].addAll({
                                      '1': [0]
                                    });
                                    break;
                                  case 'bodyweight':
                                    exercisesToAdd[i]['lastTraining'].addAll({
                                      '1': [0]
                                    });
                                    break;
                                }

                                exercises.add(exercisesToAdd[i]);
                              }
                              exercisesToAdd.clear();
                              reNewSortingNumbers();
                            });
                          }),
                      child: Text('Add Exercise')),
                  ElevatedButton(
                      onPressed: () {
                        // print(exercises);
                        // print('======');
                        // print(copyOfExercises);
                        trySubmit();
                        Navigator.of(context).pop();
                      },
                      child: Text('Submit'))
                ],
              ),
            ),
    ));
  }
}
