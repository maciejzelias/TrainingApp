import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_app/classes/Training.dart';
import 'package:training_app/widgets/calendar.dart';
import 'package:training_app/widgets/template_card.dart';

import '../screens/training_Screen.dart';

void isolateFunction(SendPort mySendPort) async {
  late TrainingScreen trainingscreen;
  ReceivePort IsolatedReceivePort = ReceivePort();
  mySendPort.send(IsolatedReceivePort.sendPort);
  SendPort secondSendPort;
  Training training;
  String title;
  List isolates;
  await for (var message in IsolatedReceivePort) {
    title = message[0];
    List ex = message[1];
    secondSendPort = message[2];
    isolates = message[3];
    training = new Training.second(ex, title);
    trainingscreen = TrainingScreen.second(training, isolates);
    secondSendPort.send(trainingscreen);
  }
}

class HomeWidget extends StatefulWidget {
  bool _isWorkout;
  HomeWidget(this._isWorkout);

  @override
  State<HomeWidget> createState() => _HomeWidgetState(_isWorkout);
}

class _HomeWidgetState extends State<HomeWidget> {
  late var trainingscreen;
  ReceivePort mikeResponseReceivePort = ReceivePort();
  ReceivePort myReceivePort = ReceivePort();
  _HomeWidgetState(this._isWorkout) {
    // this.trainingscreen = null;
  }
  bool _isWorkout;
  List<dynamic> ex = [];
  String title = 'Empty Workout';
  late List isolates = [];
  void refresh() {
    setState(() {
      _isWorkout = true;
    });
  }

  String id = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    // final _trainingScreenNotifier = context.watch<trainingScreenNotifier>();
    return Stack(
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('Training Templates',
                            style: GoogleFonts.roboto(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontSize: 30)),
                      ),
                      Container(
                        margin: const EdgeInsets.all(5),
                        alignment: Alignment.topCenter,
                        height: MediaQuery.of(context).size.height * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users/$id/templates')
                              .where('title', isNull: false)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return Center(child: CircularProgressIndicator());
                            var documents = snapshot.data!.docs;
                            documents.sort(
                              (a, b) => (a['title'].compareTo(b['title'])),
                            );

                            return ListView.builder(
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              scrollDirection: Axis.horizontal,
                              itemCount: documents.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0)
                                  return TemplateCard.second();
                                else
                                  return TemplateCard(
                                      documents[index - 1].reference,
                                      documents[index - 1]['title'],
                                      _isWorkout);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          // if (trainingscreen == null) {
                          //   ex = [];
                          //   ReceivePort myReceivePort = ReceivePort();
                          //   isolates.clear();
                          //   isolates.add(await Isolate.spawn(
                          //       isolateFunction, myReceivePort.sendPort));
                          //   SendPort IsolatedSendPort =
                          //       await myReceivePort.first;
                          //   ReceivePort IsolatedResponseReceivePort =
                          //       ReceivePort();
                          //   IsolatedSendPort.send([
                          //     title,
                          //     ex,
                          //     IsolatedResponseReceivePort.sendPort,
                          //     isolates
                          //   ]);
                          //   trainingscreen =
                          //       await IsolatedResponseReceivePort.first;
                          //   showModalBottomSheet<dynamic>(
                          //       isScrollControlled: true,
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return _trainingScreenNotifier
                          //             .getTrainingScreen();
                          //       });
                          //   // trainingscreen = null;
                          // }
                          // // Navigator.push(
                          // //     context,
                          // //     MaterialPageRoute(
                          // //         builder: ((context) => trainingscreen)));
                          // // Navigator.push(
                          // //     context,
                          // //     MaterialPageRoute(
                          // //         builder: ((context) => TrainingScreen.second(
                          // //             new Training.second(ex, title)))));
                        },
                        icon: Icon(Icons.fitness_center),
                        label: Text('Start Empty Workout'),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                            onPrimary: Theme.of(context).secondaryHeaderColor,
                            side: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor,
                                width: 0.3),
                            shadowColor: Theme.of(context).secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30))),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02)
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                  child: Text('History',
                      style: GoogleFonts.roboto(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 30)),
                ),
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6.0,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      color: Colors.transparent,
                      child: IconButton(
                        color: Colors.white,
                        splashColor: Theme.of(context).colorScheme.secondary,
                        icon: Icon(size: 50, Icons.calendar_month),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) =>
                                  CustomCalendar());
                        },
                      ),
                    ),
                  ),
                )
              ],
            )),
      ],
    );
  }
}
