import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:training_app/classes/Training.dart';
import 'package:training_app/widgets/choose_exercises_dialog.dart';

class NewWorkoutScreen extends StatefulWidget {
  late final Training training;
  NewWorkoutScreen() {}

  @override
  _NewWorkoutScreenState createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  late Training training;

  _NewWorkoutScreenState() {}

  String nameOfWorkout = 'Custom Workout';

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  final List<String> gropus = [
    'Back',
    'Chest',
    'Legs',
    'Shoulders',
    'Core',
    'Arms'
  ];
  List<Map<dynamic, dynamic>> exercises = [];

  Duration duration = Duration();
  Timer? timer;
  bool hasMinutes = false;
  bool hasHours = false;

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  void dispose() {
    super.dispose();

    timer?.cancel();
  }

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
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void finishWorkout() {}
  Widget buildTimer() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
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

  Widget addExercise() {
    return ElevatedButton(
      onPressed: () => showDialog(
          context: context,
          builder: (context) => ChooseExercisesDialog(exercises)).then((_) {
        setState(() {});
      }),
      child: Text('Add Exercise'),
    );
  }

  // Padding(
  //     padding: EdgeInsets.only(
  //         right: MediaQuery.of(context).size.width * 0.02),
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(primary: Colors.green),
  //       onPressed: (() {}),
  //       child: Text('Finish'),
  //     ))

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            color: Colors.grey,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(children: <Widget>[
                buildTimer(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                addExercise(),
              ]),
            ),
          );
        },
      ),
    );
  }
}
