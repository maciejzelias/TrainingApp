import 'dart:math';

import 'package:flutter/material.dart';

class ExerciseInTraining extends StatefulWidget {
  late Map exercise;
  late List<dynamic> trainingExercises;

  ExerciseInTraining(this.exercise, this.trainingExercises);

  @override
  State<ExerciseInTraining> createState() =>
      _ExerciseInTrainingState(exercise, trainingExercises);
}

class _ExerciseInTrainingState extends State<ExerciseInTraining> {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  late Map exercise;
  late int numberOfSetsLastTraining;
  late typeOfExercise type;
  late List<dynamic> trainingExercises;
  List<bool> checked = [];
  List<TextEditingController> weightControllers = [];
  List<TextEditingController> repsControllers = [];
  List<TextEditingController> timeControllers = [];
  _ExerciseInTrainingState(this.exercise, this.trainingExercises) {
    numberOfSetsLastTraining = exercise['numberOfSets'];
    exercise['numberOfSetsPreviousTraining'] = numberOfSetsLastTraining;
    switch (exercise['type']) {
      case 'weight':
        type = typeOfExercise.weight;
        for (int i = 0; i < numberOfSetsLastTraining; i++) {
          checked.add(false);
          weightControllers.add(new TextEditingController());
          repsControllers.add(new TextEditingController());
        }
        break;
      case 'bodyweight+':
        type = typeOfExercise.bodyweightPlus;
        for (int i = 0; i < numberOfSetsLastTraining; i++) {
          checked.add(false);
          weightControllers.add(new TextEditingController());
          repsControllers.add(new TextEditingController());
        }
        break;
      case 'bodyweight':
        type = typeOfExercise.bodyweight;
        for (int i = 0; i < numberOfSetsLastTraining; i++) {
          checked.add(false);
          repsControllers.add(new TextEditingController());
        }
        break;
      case 'time':
        type = typeOfExercise.time;
        for (int i = 0; i < numberOfSetsLastTraining; i++) {
          checked.add(false);
          timeControllers.add(new TextEditingController());
        }
        break;
    }
    exercise['checked'] = checked;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (int i = 0; i < exercise['numberOfSets']; i++) {
      weightControllers.elementAt(i).dispose();
      repsControllers.elementAt(i).dispose();
    }
    super.dispose();
  }

  Widget addSetButton() {
    switch (type) {
      case typeOfExercise.weight:
        return TextButton(
            onPressed: () {
              exercise['numberOfSets']++;
              exercise['lastTraining'].addAll({
                exercise['numberOfSets'].toString(): [0, 0]
              });
              checked.add(false);
              weightControllers.add(new TextEditingController());
              repsControllers.add(new TextEditingController());

              setState(() {});
            },
            child: Text('+ Add set'),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).secondaryHeaderColor));
      case typeOfExercise.bodyweightPlus:
        return TextButton(
            onPressed: () {
              setState(() {
                exercise['numberOfSets']++;
                exercise['lastTraining'].addAll({
                  exercise['numberOfSets'].toString(): [0, 0]
                });
                checked.add(false);
                weightControllers.add(new TextEditingController());
                repsControllers.add(new TextEditingController());
              });
            },
            child: Text('+ Add set'),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).secondaryHeaderColor));
      case typeOfExercise.time:
        return TextButton(
            onPressed: () {
              setState(() {
                exercise['numberOfSets']++;
                exercise['lastTraining'].addAll({
                  exercise['numberOfSets'].toString(): [0]
                });
                checked.add(false);
                timeControllers.add(new TextEditingController());
              });
            },
            child: Text('+ Add set'),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).secondaryHeaderColor));
      case typeOfExercise.bodyweight:
        return TextButton(
            onPressed: () {
              setState(() {
                exercise['numberOfSets']++;
                exercise['lastTraining'].addAll({
                  exercise['numberOfSets'].toString(): [0]
                });
                checked.add(false);
                repsControllers.add(new TextEditingController());
              });
            },
            child: Text('+ Add set'),
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).secondaryHeaderColor));
    }
  }

  bool isThatAddedSet(int index) {
    if (exercise['numberOfSetsPreviousTraining'] == exercise['numberOfSets']) {
      return false;
    } else {
      if (index + 1 >= numberOfSetsLastTraining) {
        return true;
      }
      return false;
    }
  }

  bool isThatOneFieldSet() {
    if (type == typeOfExercise.bodyweight || type == typeOfExercise.time) {
      return true;
    }
    return false;
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  void removeSet(int index) {
    exercise['numberOfSets']--;
    checked.removeAt(index);
    exercise['lastTraining'].remove((index + 1).toString());
    for (int i = index + 2; i <= exercise['numberOfSets'] + 1; i++) {
      var _set = exercise['lastTraining'][i.toString()];
      exercise['lastTraining'].addAll({(i - 1).toString(): _set});
      exercise['lastTraining'].remove(i.toString());
    }
  }

  Widget removeSetIcon(int index) {
    switch (type) {
      case typeOfExercise.weight:
        return IconButton(
          onPressed: () {
            setState(() {
              weightControllers.removeAt(index);
              repsControllers.removeAt(index);
              removeSet(index);
            });
          },
          icon: Icon(Icons.remove_circle),
          color: Theme.of(context).secondaryHeaderColor,
        );
      case typeOfExercise.bodyweightPlus:
        return IconButton(
          onPressed: () {
            setState(() {
              weightControllers.removeAt(index);
              repsControllers.removeAt(index);
              removeSet(index);
            });
          },
          icon: Icon(Icons.remove_circle),
          color: Theme.of(context).secondaryHeaderColor,
        );
      case typeOfExercise.time:
        return IconButton(
          onPressed: () {
            setState(() {
              timeControllers.removeAt(index);
              removeSet(index);
            });
          },
          icon: Icon(Icons.remove_circle),
          color: Theme.of(context).secondaryHeaderColor,
        );
      case typeOfExercise.bodyweight:
        return IconButton(
          onPressed: () {
            setState(() {
              repsControllers.removeAt(index);
              removeSet(index);
            });
          },
          icon: Icon(Icons.remove_circle),
          color: Theme.of(context).secondaryHeaderColor,
        );
    }
  }

  Widget rowForWeightExercise(int index) {
    return Dismissible(
      key: Key(exercise['lastTraining'].toString()),
      onDismissed: (direction) {
        setState(() {
          weightControllers.removeAt(index);
          repsControllers.removeAt(index);
          removeSet(index);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text((index + 1).toString()),
          Expanded(child: removeSetIcon(index)),
          Expanded(
            child: TextField(
              enabled: !checked.elementAt(index),
              controller: weightControllers.elementAt(index),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  label: isThatAddedSet(index)
                      ? Text('0')
                      : Text(exercise['lastTraining'][(index + 1).toString()][0]
                          .toString())),
            ),
          ),
          Expanded(
            child: TextField(
              enabled: !checked.elementAt(index),
              controller: repsControllers.elementAt(index),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  label: isThatAddedSet(index)
                      ? Text('0')
                      : Text(exercise['lastTraining'][(index + 1).toString()][1]
                          .toString())),
            ),
          ),
          Checkbox(
            checkColor: Colors.transparent,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: checked.elementAt(index),
            onChanged: (bool? value) {
              setState(() {
                checked[index] = value!;
                if (value) {
                  exercise['lastTraining'][(index + 1).toString()][0] =
                      int.parse(weightControllers.elementAt(index).text);
                  exercise['lastTraining'][(index + 1).toString()][1] =
                      int.parse(repsControllers.elementAt(index).text);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget rowForBodyWeightPlusExercise(int index) {
    return Dismissible(
      key: Key(exercise['lastTraining'].toString()),
      onDismissed: (direction) {
        setState(() {
          weightControllers.removeAt(index);
          repsControllers.removeAt(index);
          removeSet(index);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text((index + 1).toString()),
          Expanded(child: removeSetIcon(index)),
          Expanded(
            child: TextField(
              enabled: !checked.elementAt(index),
              controller: weightControllers.elementAt(index),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  label: isThatAddedSet(index)
                      ? Text('0')
                      : Text(exercise['lastTraining'][(index + 1).toString()][0]
                          .toString())),
            ),
          ),
          Expanded(
            child: TextField(
              enabled: !checked.elementAt(index),
              controller: repsControllers.elementAt(index),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  label: isThatAddedSet(index)
                      ? Text('0')
                      : Text(exercise['lastTraining'][(index + 1).toString()][1]
                          .toString())),
            ),
          ),
          Checkbox(
            checkColor: Colors.transparent,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: checked.elementAt(index),
            onChanged: (bool? value) {
              setState(() {
                checked[index] = value!;
                if (value) {
                  exercise['lastTraining'][(index + 1).toString()][0] =
                      int.parse(weightControllers.elementAt(index).text);
                  exercise['lastTraining'][(index + 1).toString()][1] =
                      int.parse(repsControllers.elementAt(index).text);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget rowForTimeExercise(int index) {
    return Dismissible(
      key: Key(exercise['lastTraining'].toString()),
      onDismissed: (direction) {
        setState(() {
          timeControllers.removeAt(index);
          removeSet(index);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text((index + 1).toString()),
          Expanded(child: removeSetIcon(index)),
          Expanded(
            child: TextField(
              enabled: !checked.elementAt(index),
              controller: timeControllers.elementAt(index),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  label: isThatAddedSet(index)
                      ? Text('0')
                      : Text(exercise['lastTraining'][(index + 1).toString()][0]
                          .toString())),
            ),
          ),
          Checkbox(
            checkColor: Colors.transparent,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: checked.elementAt(index),
            onChanged: (bool? value) {
              setState(() {
                checked[index] = value!;
                if (value) {
                  exercise['lastTraining'][(index + 1).toString()][0] =
                      int.parse(timeControllers.elementAt(index).text);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget rowForBodyweightExercise(int index) {
    return Dismissible(
      key: Key(exercise['lastTraining'].toString()),
      onDismissed: (direction) {
        setState(() {
          repsControllers.removeAt(index);
          removeSet(index);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text((index + 1).toString()),
          Expanded(child: removeSetIcon(index)),
          Expanded(
            child: TextField(
              enabled: !checked.elementAt(index),
              controller: repsControllers.elementAt(index),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  label: isThatAddedSet(index)
                      ? Text('0')
                      : Text(exercise['lastTraining'][(index + 1).toString()][0]
                          .toString())),
            ),
          ),
          Checkbox(
            checkColor: Colors.transparent,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: checked.elementAt(index),
            onChanged: (bool? value) {
              setState(() {
                checked[index] = value!;
                if (value) {
                  exercise['lastTraining'][(index + 1).toString()][0] =
                      int.parse(repsControllers.elementAt(index).text);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget exerciseTitle() {
    switch (type) {
      case typeOfExercise.weight:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [Text('kg'), Text('Reps')],
        );
      case typeOfExercise.bodyweightPlus:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [Text('+kg'), Text('Reps')],
        );
      case typeOfExercise.time:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [Text('time')],
        );
      case typeOfExercise.bodyweight:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [Text('reps')],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      child: Column(
        children: [
          Text(exercise['name']),
          exerciseTitle(),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise['numberOfSets'],
              itemBuilder: ((context, index) {
                switch (type) {
                  case typeOfExercise.weight:
                    return rowForWeightExercise(index);
                  case typeOfExercise.bodyweightPlus:
                    return rowForBodyWeightPlusExercise(index);
                  case typeOfExercise.time:
                    return rowForTimeExercise(index);
                  case typeOfExercise.bodyweight:
                    return rowForBodyweightExercise(index);
                }
              })),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              addSetButton(),
            ],
          ),
        ],
      ),
    );
  }
}

enum typeOfExercise { weight, bodyweightPlus, time, bodyweight }
