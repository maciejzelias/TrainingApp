import 'package:flutter/material.dart';

class ExerciseCard extends StatefulWidget {
  late final List ex;
  late final Map doc;
  late String part;
  ExerciseCard(List ex, Map doc, this.part) {
    this.ex = ex;
    this.doc = doc;
  }

  @override
  State<ExerciseCard> createState() => _ExerciseCardState(ex, doc, part);
}

class _ExerciseCardState extends State<ExerciseCard> {
  late Map doc;
  bool _isTap = false;
  late List exercises;
  late String part;
  _ExerciseCardState(List ex, Map doc, this.part) {
    this.doc = doc;
    this.exercises = ex;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTap = !_isTap;
          if (_isTap) {
            doc['part'] = part;
            doc['numberOfSets'] = 1;
            exercises.add(doc);
          } else
            exercises.remove(doc);
        });
      },
      child: Card(
        color: _isTap ? Theme.of(context).colorScheme.secondary : Colors.white,
        child: Container(
          child: Row(
            children: [Text(doc['name'])],
          ),
        ),
      ),
    );
  }
}
