import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:training_app/widgets/choose_exercises_dialog.dart';
import 'package:training_app/widgets/exercise_in_template.dart';

class NewTemplate extends StatefulWidget {
  const NewTemplate({Key? key}) : super(key: key);

  @override
  State<NewTemplate> createState() => _NewTemplateState();
}

class _NewTemplateState extends State<NewTemplate> {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  void refresh() {
    setState(() {});
  }

  bool _isLoading = false;
  String _title = "";
  final _formKey = GlobalKey<FormState>();
  final List<String> gropus = [
    'Back',
    'Chest',
    'Legs',
    'Shoulders',
    'Core',
    'Arms'
  ];
  List<Map<dynamic, dynamic>> exercises = [];

  void trySubmit() async {
    setState(() {
      _isLoading = true;
    });
    bool isValidate = await _formKey.currentState!.validate();
    if (isValidate) {
      Map mapa = {};
      _formKey.currentState!.save();
      String id = await FirebaseAuth.instance.currentUser!.uid;
      var doc = await FirebaseFirestore.instance
          .collection('users/$id/templates')
          .doc();
      await doc.set({'title': _title});
      for (int i = 0; i < exercises.length; i++) {
        mapa = {};
        for (int j = 1; j <= exercises[i]['numberOfSets']; j++) {
          switch (exercises[i]['type']) {
            case 'weight':
              mapa.addAll({
                j.toString(): [0, 0]
              });
              break;
            case 'time':
              mapa.addAll({
                j.toString(): [0]
              });
              break;
            case 'bodyweight+':
              mapa.addAll({
                j.toString(): [0, 0]
              });
              break;
            case 'bodyweight':
              mapa.addAll({
                j.toString(): [0]
              });
              break;
          }
        }
        await doc.collection('exercises').add({
          'part': exercises[i]['part'],
          'name': exercises[i]['name'],
          'type': exercises[i]['type'],
          'numberOfSets': exercises[i]['numberOfSets'],
          'lastTraining': mapa,
          'sortingNumber': i,
        });
      }
    }
    setState(() {
      _isLoading = false;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a new training template')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  onSaved: (newValue) {
                    _title = newValue!;
                  },
                  validator: (value) {
                    if (value!.length == 0) return "Please enter a title";
                    return null;
                  },
                  decoration: InputDecoration(
                      fillColor: Colors.grey.withOpacity(0.6),
                      labelText: 'Template title'),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  key: new Key(getRandomString(5)),
                  shrinkWrap: true,
                  itemCount: exercises.length,
                  itemBuilder: ((context, index) {
                    return ExerciseInTemplate(
                        exercises[index], exercises, refresh, index);
                  })),
              ElevatedButton(
                  onPressed: () => showDialog(
                          context: context,
                          builder: (context) =>
                              ChooseExercisesDialog(exercises)).then((_) {
                        setState(() {});
                      }),
                  child: Text('Add Exercise')),
              ElevatedButton(
                  onPressed: () {
                    trySubmit();
                  },
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Submit Template'))
            ],
          ),
        ),
      ),
    );
  }
}
