import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddExerciseDialog extends StatefulWidget {
  late final Function() notifyParent;
  late final String type;
  AddExerciseDialog(this.type, this.notifyParent) {}

  @override
  State<AddExerciseDialog> createState() =>
      _AddExerciseDialogState(type, notifyParent);
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  late Function() notifyParent;
  _AddExerciseDialogState(this.part, this.notifyParent) {}
  late String part;
  String _actualType = "Weight";
  bool _isValid = true;
  TextEditingController controller = TextEditingController();
  final List<String> categories = [
    'Weight',
    'Weighted Bodyweight',
    'Duration',
    'Bodyweight'
  ];
  void trySubmit() async {
    String type = "";
    switch (_actualType) {
      case 'Weight':
        type = 'weight';
        break;
      case 'Weighted Bodyweight':
        type = 'bodyweight+';
        break;
      case 'Duration':
        type = 'time';
        break;
      case 'Bodyweight':
        type = 'bodyweight';
        break;
    }
    String uid = await FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users/$uid/exercises/$part/exercises')
        .add({'name': controller.text, 'type': type});
    notifyParent();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
                child: Text(
              'Add your custom exercise',
              style: TextStyle(fontSize: 15),
            )),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Title',
                  errorText: _isValid ? null : 'Please enter a title'),
              controller: controller,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Category : '),
                DropdownButton(
                    value: _actualType,
                    items: categories.map((String type) {
                      return DropdownMenuItem(
                        child: Text(type),
                        value: type,
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _actualType = newValue!;
                      });
                    })
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (controller.text.isEmpty)
                    setState(() {
                      _isValid = false;
                    });
                  else
                    _isValid = true;
                  if (_isValid) {
                    trySubmit();
                    Navigator.pop(context, true);
                  }
                },
                child: Text('Add Exercise'))
          ],
        ),
      )),
    );
  }
}
