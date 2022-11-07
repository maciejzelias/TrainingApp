import 'package:flutter/material.dart';

class ExerciseInTemplate extends StatefulWidget {
  final Function() notifyParent;
  final Map map;
  final List exercises;
  final int index;
  ExerciseInTemplate(this.map, this.exercises, this.notifyParent, this.index) {}

  @override
  State<ExerciseInTemplate> createState() =>
      _ExerciseInTemplateState(map, exercises, notifyParent, index);
}

class _ExerciseInTemplateState extends State<ExerciseInTemplate> {
  late Function() notifyParent;
  late int _numberOfSets;
  late Map exercise;
  late Map copyOfexercise;
  late List exercises;
  late int index;
  _ExerciseInTemplateState(
      this.exercise, this.exercises, this.notifyParent, this.index) {
    try {
      _numberOfSets = this.exercise['numberOfSets'];
    } catch (Exception) {
      this.exercise['numberOfSets'] = 1;
      _numberOfSets = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exercise['name'],
              ),
              IconButton(
                  onPressed: () {
                    exercises.remove(exercise);
                    notifyParent();
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
                      if (_numberOfSets > 1) _numberOfSets--;
                      exercise['numberOfSets'] = _numberOfSets;
                    });
                  },
                  icon: Icon(Icons.remove)),
              Text(_numberOfSets.toString()),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _numberOfSets++;
                      exercise['numberOfSets'] = _numberOfSets;
                    });
                  },
                  icon: Icon(Icons.add))
            ],
          )
        ],
      ),
    );
  }
}
