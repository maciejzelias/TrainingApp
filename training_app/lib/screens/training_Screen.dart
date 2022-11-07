// import 'dart:html';

import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:training_app/screens/take_picture_screen.dart' show TakePictureScreen;
import 'package:training_app/widgets/exercise_in_Training.dart' show ExerciseInTraining;
import 'package:collection/collection.dart';

import '../classes/Training.dart';
import '../widgets/choose_exercises_dialog.dart';
import 'home_screen.dart' show trainingScreenNotifier;

class TrainingScreen extends StatefulWidget {
  late List isolates;
  late Training training;
  late List<QueryDocumentSnapshot<Object?>> exercisesTemplate;
  DocumentReference? template;
  // late ScrollController scrollController;
  late bool isFromTemplate;

  TrainingScreen(
      this.training, this.exercisesTemplate, this.template, this.isolates) {
    this.isFromTemplate = true;
  }

  TrainingScreen.second(this.training, this.isolates) {
    exercisesTemplate = [];
    this.isFromTemplate = false;
  }

  @override
  State<TrainingScreen> createState() => _TrainingScreenState(
      training, exercisesTemplate, isFromTemplate, template, isolates);
}

class _TrainingScreenState extends State<TrainingScreen> {
  late String docId = "";
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  late Training training;
  late String title = 'custom';
  late bool isFromTemplate;
  late final List<dynamic> copyOfExercises;
  late List<QueryDocumentSnapshot<Object?>> exercisesTemplate;
  late ScrollController scrollController;
  late bool restTimerOn;
  DocumentReference? template;
  late List isolates;
  _TrainingScreenState(this.training, this.exercisesTemplate,
      this.isFromTemplate, this.template, this.isolates) {
    this.restTimerOn = false;
    this.title = training.title;
    this.copyOfExercises = training.exercises.toList();
  }

  Duration duration = Duration();
  Timer? timer;
  bool hasMinutes = false;
  bool hasHours = false;
  void addTime() {
    final addSeconds = 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;

      duration = Duration(seconds: seconds);
      if (duration.inMinutes >= 1) {
        hasMinutes = true;
      }
      if (duration.inHours >= 1) {
        hasHours = true;
      }
      // duration = training.duration;
      // print(duration);
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool _isLoading = false;

  bool wasTemplateChanged() {
    bool wynik = false;
    if (!copyOfExercises.equals(training.exercises.toList())) {
      wynik = true;
    }
    for (int i = 0; i < training.exercises.length; i++) {
      if (training.exercises[i]['numberOfSets'] !=
          training.exercises[i]['numberOfSetsPreviousTraining']) {
        wynik = true;
      }
    }
    return wynik;
  }

  void optimizeTraining() {
    List<bool> checked = [];
    Map mapa = {};
    int counter;
    for (int i = 0; i < training.exercises.length; i++) {
      counter = 1;
      checked = training.exercises[i]['checked'];
      mapa = {};
      for (int b = 0; b < checked.length; b++) {
        if (checked.elementAt(b)) {
          mapa.addAll({
            counter.toString(): training.exercises[i]['lastTraining']
                [(b + 1).toString()]
          });
          counter++;
        }
      }
      checked.removeWhere(((element) => !element));
      setState(() {
        training.exercises[i]['lastTraining'] = mapa;
        training.exercises[i]['numberOfSets'] = counter - 1;
      });
    }

    for (int i = 0; i < training.exercises.length; i++) {
      if (training.exercises[i]['numberOfSets'] == 0) {
        training.exercises.removeAt(i);
        i--;
      }
    }
  }

  void updateTemplate() async {
    for (int i = 0; i < copyOfExercises.length; i++) {
      exercisesTemplate
          .elementAt(i)
          .reference
          .update({'lastTraining': training.exercises[i]['lastTraining']});
    }
  }

  Future<T> hackyDeepCopy<T>(T object) async =>
      await (ReceivePort()..sendPort.send(object)).first as T;

  void updateChangedTemplate() async {
    final List<dynamic> kopia = await hackyDeepCopy(copyOfExercises);
    Map map = {};
    int originalNumberOfSets;
    int numberOfSets;
    for (int i = 0; i < copyOfExercises.length; i++) {
      originalNumberOfSets =
          copyOfExercises.elementAt(i)['numberOfSetsPreviousTraining'];
      map = kopia.elementAt(i)['lastTraining'];
      numberOfSets = copyOfExercises.elementAt(i)['numberOfSets'];

      if (numberOfSets != 0) {
        if (numberOfSets > originalNumberOfSets) {
          for (int b = originalNumberOfSets + 1; b <= numberOfSets; b++) {
            map.remove(b.toString());
          }
        } else if (numberOfSets < originalNumberOfSets) {
          for (int b = numberOfSets + 1; b <= originalNumberOfSets; b++) {
            map.addAll(kopia.elementAt(i)['lastTraining'][b.toString()]);
          }
        }
        exercisesTemplate.elementAt(i).reference.update({'lastTraining': map});
      }
    }
  }

  void upgradeTemplate() async {
    exercisesTemplate.forEach((element) {
      element.reference.delete();
    });

    var doc = template as DocumentReference<Map<String, dynamic>>;

    addExercisesToDocument(doc);
  }

  void addExercisesToDocument(
      DocumentReference<Map<String, dynamic>> doc) async {
    for (int i = 0; i < training.exercises.length; i++) {
      await doc.collection('exercises').add({
        'part': training.exercises[i]['part'],
        'name': training.exercises[i]['name'],
        'type': training.exercises[i]['type'],
        'numberOfSets': training.exercises[i]['numberOfSets'],
        'lastTraining': training.exercises[i]['lastTraining'],
        'sortingNumber': i,
      });
    }
  }

  void createTemplate(String title) async {
    String id = await FirebaseAuth.instance.currentUser!.uid;

    var doc = await FirebaseFirestore.instance
        .collection('users/$id/templates')
        .doc();

    await doc.set({'title': this.title});

    addExercisesToDocument(doc);
  }

  Future trySubmit() async {
    setState(() {
      _isLoading = true;
    });
    int time = DateTime.now().millisecondsSinceEpoch;
    String id = await FirebaseAuth.instance.currentUser!.uid;
    var doc =
        await FirebaseFirestore.instance.collection('users/$id/history').doc();
    docId = doc.id;
    await doc
        .set({'title': title, 'date': time, 'duration': duration.inSeconds});

    addExercisesToDocument(doc);

    for (int i = 0; i < training.exercises.length; i++) {
      String name = training.exercises[i]['name'];
      var doc = await FirebaseFirestore.instance
          .collection('users/$id/exercisesPerformed')
          .doc(name)
          .get();
      if (doc.exists) {
        await FirebaseFirestore.instance
            .collection('users/$id/exercisesPerformed/$name/history')
            .add({
          'date': time,
          'numberOfSets': training.exercises[i]['numberOfSets'],
          'lastTraining': training.exercises[i]['lastTraining']
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users/$id/exercisesPerformed')
            .doc(name)
            .set({
          'part': training.exercises[i]['part'],
          'type': training.exercises[i]['type'],
          'name': name
        });

        await FirebaseFirestore.instance
            .collection('users/$id/exercisesPerformed/$name/history')
            .add({
          'date': time,
          'numberOfSets': training.exercises[i]['numberOfSets'],
          'lastTraining': training.exercises[i]['lastTraining']
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  Widget buildTimer() {
    final hours = twoDigits(duration.inHours.remainder(60));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Duration:',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        Row(
          children: [
            Visibility(
              child: Text(
                '$hours:',
                style: TextStyle(fontSize: 20),
              ),
              visible: hasHours,
            ),
            Visibility(
              child: Text(
                '$minutes:',
                style: TextStyle(fontSize: 20),
              ),
              visible: hasMinutes,
            ),
            Text(
              '$seconds',
              style: TextStyle(fontSize: 20),
            ),
          ],
        )
      ],
    );
  }

  bool isPressed = false;
  Timer? timerRest;
  Duration restDuration = Duration(seconds: 180);
  Duration saveDurationAfterCancel = Duration(seconds: 180);
  bool isCompleted = false;
  Widget restTimer() {
    return Column(
      children: <Widget>[
        IconButton(
            onPressed: () {
              setState(() {
                restTimerOn = !restTimerOn;
              });
            },
            icon: Icon(Icons.timer)),
        Visibility(
          visible: restTimerOn,
          child: GestureDetector(
              child: Text(twoDigits(restDuration.inMinutes.remainder(60)) +
                  ' : ' +
                  twoDigits(restDuration.inSeconds.remainder(60))),
              onTap: () async {
                timerRest?.cancel();
                isPressed = false;
                await showDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoTimerPicker(
                        minuteInterval: 1,
                        secondInterval: 5,
                        initialTimerDuration: restDuration,
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        mode: CupertinoTimerPickerMode.ms,
                        onTimerDurationChanged: (time) {
                          setState(() {
                            restDuration = time;
                            saveDurationAfterCancel = time;
                          });
                        },
                      );
                    });
              }),
        ),
        Visibility(
          visible: restTimerOn,
          child: IconButton(
            icon: (isPressed) ? Icon(Icons.stop) : Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                isPressed = !isPressed;
              });
              if (isPressed) {
                timerRest = Timer.periodic(
                    Duration(seconds: 1),
                    (_) => setState(() {
                          if (restDuration.inSeconds <= 1) {
                            timerRest?.cancel();
                          }
                          restDuration =
                              Duration(seconds: (restDuration.inSeconds - 1));
                        }));
              } else {
                timerRest?.cancel();
                restDuration = saveDurationAfterCancel;
              }
            },
          ),
        ),
      ],
    );
  }

  List<Map<dynamic, dynamic>> exercises = [];

  Widget addExercise() {
    return TextButton(
        onPressed: () => showDialog(
                    context: context,
                    builder: (context) => ChooseExercisesDialog(exercises))
                .then((_) {
              setState(() {
                for (int i = 0; i < exercises.length; i++) {
                  exercises[i]['numberOfSets'] = 1;
                  exercises[i]['lastTraining'] = new Map<dynamic, dynamic>();
                  switch (exercises[i]['type']) {
                    case 'weight':
                      exercises[i]['lastTraining'].addAll({
                        '1': [0, 0]
                      });
                      break;
                    case 'bodyweight+':
                      exercises[i]['lastTraining'].addAll({
                        '1': [0, 0]
                      });
                      break;
                    case 'time':
                      exercises[i]['lastTraining'].addAll({
                        '1': [0]
                      });
                      break;
                    case 'bodyweight':
                      exercises[i]['lastTraining'].addAll({
                        '1': [0]
                      });
                      break;
                  }
                }
              });
              setState(() {
                for (int i = 0; i < exercises.length; i++) {
                  training.exercises.add(exercises[i]);
                }
                exercises.clear();
              });
              print(training.exercises);
            }),
        child: Text(
          'Add Exercise',
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary));
  }

  Widget removeExercise(int index) {
    return IconButton(
        onPressed: () {
          setState(() {
            training.exercises.removeAt(index);
            print(training.exercises);
          });
        },
        icon: Icon(
          Icons.delete,
          color: Theme.of(context).secondaryHeaderColor,
        ));
  }

  Widget cancelOrSubmitTraining() {
    final _trainingScreenNotifier = context.read<trainingScreenNotifier>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            final value = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Are you sure you want to finish training?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text('Yes'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                });
            if (value == true) {
              optimizeTraining();
              if (isFromTemplate) {
                if (wasTemplateChanged()) {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                              'You have made some changes, would you like to update your template?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('No'),
                              onPressed: () {
                                updateChangedTemplate();
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Yes'),
                              onPressed: () {
                                upgradeTemplate();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                } else {
                  updateTemplate();
                }
              } else {
                await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(
                            'Would you like to add this training to templates?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () async {
                              TextEditingController newTitleController =
                                  new TextEditingController();
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Name your workout'),
                                      content: TextField(
                                        controller: newTitleController,
                                        decoration: InputDecoration(
                                          hintText: "Empty workout",
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            this.title =
                                                newTitleController.text;
                                            createTemplate(
                                                newTitleController.text);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Ok'),
                                        )
                                      ],
                                    );
                                  });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              }

              await trySubmit();

              await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: Card(
                          child: Column(
                            children: [
                              Text(
                                  'Would you like to do an after workout photo?'),
                              Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    TakePictureScreen(
                                                      docId: docId,
                                                    ))));
                                        // Navigator.of(context).pop();
                                      },
                                      child: Text('Yes')),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('No'))
                                ],
                              )
                            ],
                          ),
                        ),
                      ));
              Navigator.of(context).pop;
              isolates[0].kill(priority: Isolate.immediate);
              _trainingScreenNotifier.removeTrainingScreen();
            }
          },
          child: _isLoading
              ? CircularProgressIndicator()
              : Text('Submit Training'),
          style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 90, 233, 77)),
        ),
        ElevatedButton(
          onPressed: () async {
            await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Are you sure you want to exit?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Yes, exit'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _trainingScreenNotifier.removeTrainingScreen();
                          isolates[0].kill(priority: Isolate.immediate);
                        },
                      ),
                    ],
                  );
                });
          },
          child: Text('Cancel Training'),
          style: TextButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  //   scrollController.jumpTo(0.13);
                },
                icon: Icon(Icons.arrow_downward)),
            Center(
              child: Text(
                'Training : $title',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [buildTimer(), restTimer()],
            ),
            Expanded(
              child: SingleChildScrollView(
                primary: true,
                child: Column(
                  children: [
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: training.exercises.length,
                        itemBuilder: ((context, index) {
                          return Container(
                            key: Key(training.exercises[index]['sortingNumber']
                                .toString()),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(context).primaryColor
                                ])),
                            child: Column(
                              children: [
                                ExerciseInTraining(training.exercises[index],
                                    training.exercises),
                                removeExercise(index),
                              ],
                            ),
                          );
                        })),
                    addExercise(),
                  ],
                ),
              ),
            ),
            cancelOrSubmitTraining(),
          ],
        ),
      ),
    );
  }
}
