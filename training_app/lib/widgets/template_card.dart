import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:training_app/classes/Training.dart';
import 'package:training_app/screens/edit_template_screen.dart';
import 'package:training_app/screens/training_Screen.dart';

import '../screens/home_screen.dart' show trainingScreenNotifier;
import 'new_template.dart';

void isolateFunction(SendPort mySendPort) async {
  late TrainingScreen trainingscreen;
  ReceivePort IsolatedReceivePort = ReceivePort();
  mySendPort.send(IsolatedReceivePort.sendPort);
  SendPort secondSendPort;
  Training training;
  String title;
  late final DocumentReference template;
  List<QueryDocumentSnapshot<Object?>> exercises;
  List isolates;
  await for (var message in IsolatedReceivePort) {
    template = message[0];
    exercises = message[1];
    title = message[2];
    List ex = message[3];
    secondSendPort = message[4];
    isolates = message[5];
    training = new Training.second(ex, title);
    trainingscreen =
        new TrainingScreen(training, exercises, template, isolates);
    secondSendPort.send(trainingscreen);
  }
}

class TemplateCard extends StatelessWidget {
  List isolates = [];
  late var trainingscreen;
  late final DocumentReference template;
  late final bool isNewTemplate;
  late String title;
  late final String id;
  late List ex = [];
  late bool isWorkout;
  TemplateCard(DocumentReference template, this.title, this.isWorkout) {
    this.template = template;
    this.isNewTemplate = false;
    this.id = FirebaseAuth.instance.currentUser!.uid;
    this.trainingscreen = null;
  }
  late QuerySnapshot exercises;
  Future fetchData() async {
    exercises = await template
        .collection('exercises')
        .orderBy('sortingNumber', descending: false)
        .get();
    ex = exercises.docs.map((doc) => doc.data()).toList();
    print(ex);
  }

  TemplateCard.second() {
    this.isNewTemplate = true;
  }

  String matchText(Map exercise, indeks) {
    String result = "";
    switch (exercise['type']) {
      case 'weight':
        result = (exercise['lastTraining'][(indeks + 1).toString()][0]
                .toString() +
            ' kg x ' +
            exercise['lastTraining'][(indeks + 1).toString()][1].toString());
        break;
      case 'bodyweight+':
        result = result = ('+ ' +
            exercise['lastTraining'][(indeks + 1).toString()][0].toString() +
            'kg x ' +
            exercise['lastTraining'][(indeks + 1).toString()][1].toString());
        break;
      case 'time':
        int seconds = exercise['lastTraining'][(indeks + 1).toString()][0];
        Duration duration = Duration(seconds: seconds);
        result =
            "${duration.inHours}:${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60))}";
        break;
      case 'bodyweight':
        result =
            exercise['lastTraining'][(indeks + 1).toString()][0].toString() +
                ' reps';
    }
    return result;
  }

  Future delete() async {
    String templateId = template.id;
    await FirebaseFirestore.instance
        .collection('users/$id/templates')
        .doc(templateId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final _trainingScreenNotifier = context.watch<trainingScreenNotifier>();
    if (isNewTemplate) {
      return GestureDetector(
          onTap: (() => showDialog(
              context: context, builder: (context) => NewTemplate())),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(96, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.3,
            child: Icon(
              FontAwesomeIcons.plus,
              size: MediaQuery.of(context).size.width * 0.1,
              color: Theme.of(context).secondaryHeaderColor,
            ),
          ));
    } else {
      return GestureDetector(
        onTap: () async {
          await fetchData();
          showGeneralDialog(
            barrierDismissible: true,
            barrierLabel: 'Label',
            context: context,
            pageBuilder: (ctx, a1, a2) {
              return Container();
            },
            transitionBuilder: (ctx, a1, a2, child) {
              var curve = Curves.easeInOut.transform(a1.value);
              return Transform.scale(
                scale: curve,
                child: Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(96, 255, 255, 255),
                        borderRadius: BorderRadius.circular(35.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(title,
                                  style: GoogleFonts.roboto(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 30)),
                            ],
                          ),
                          Card(
                            child: Column(children: [
                              ListView.builder(
                                  itemCount: ex.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: ((context, index) {
                                    return Card(
                                      child: Column(
                                        children: [
                                          Text(ex[index]['name']),
                                          ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: ex[index]
                                                  ['numberOfSets'],
                                              itemBuilder: ((context, indeks) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Text((indeks + 1)
                                                        .toString()),
                                                    Text(matchText(
                                                        ex[index], indeks))
                                                  ],
                                                );
                                              })),
                                        ],
                                      ),
                                    );
                                  }))
                            ]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        if (trainingscreen == null) {
                                          Navigator.of(context).pop();
                                          ReceivePort myReceivePort =
                                              ReceivePort();
                                          isolates.clear();
                                          isolates.add(await Isolate.spawn(
                                              isolateFunction,
                                              myReceivePort.sendPort));
                                          SendPort IsolatedSendPort =
                                              await myReceivePort.first;
                                          ReceivePort
                                              IsolatedResponseReceivePort =
                                              ReceivePort();
                                          IsolatedSendPort.send([
                                            template,
                                            exercises.docs,
                                            title,
                                            ex,
                                            IsolatedResponseReceivePort
                                                .sendPort,
                                            isolates
                                          ]);
                                          trainingscreen =
                                              await IsolatedResponseReceivePort
                                                  .first;

                                          _trainingScreenNotifier
                                              .setTrainingScreen(
                                                  trainingscreen, context);
                                          showModalBottomSheet<dynamic>(
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return _trainingScreenNotifier
                                                    .getTrainingScreen();
                                              });
                                          trainingscreen = null;
                                        }
                                      },
                                      icon: Icon(Icons.start_outlined)),
                                  Text('Start'),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    EditTemplateScreen(
                                                        template, title))));
                                      },
                                      icon: Icon(Icons.edit)),
                                  Text('Edit'),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await delete();
                                      },
                                      icon: Icon(Icons.delete)),
                                  Text('Delete'),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          )
                        ],
                      ),
                    )),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
        child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(96, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.3,
            child: Stack(
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = Colors.black,
                    fontSize: 20,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )),
      );
    }
  }
}
