import 'package:flutter/material.dart';

class RmDialog extends StatefulWidget {
  const RmDialog({Key? key}) : super(key: key);

  @override
  State<RmDialog> createState() => _RmDialogState();
}

class _RmDialogState extends State<RmDialog> {
  int result = 0;
  TextEditingController kilos = TextEditingController();
  TextEditingController reps = TextEditingController();
  double kg = 0;
  double rps = 0;
  final _formKey = GlobalKey<FormState>();
  void calculate() async {
    bool _isValid = await _formKey.currentState!.validate();

    if (_isValid) {
      _formKey.currentState!.save();
      setState(() {
        result = (kg * (36 / (37 - rps))).round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Estimate your 1RM'),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.contains(',')) {
                          value.replaceAll(RegExp(','), '.');
                        } else if (value.isEmpty || double.parse(value) < 1)
                          return 'Enter valid number';
                        return null;
                      },
                      decoration: InputDecoration(label: Text('Weight')),
                      keyboardType: TextInputType.number,
                      onSaved: (newValue) {
                        if (newValue!.contains(','))
                          newValue.replaceAll(RegExp(','), '.');
                        setState(() {
                          kg = double.parse(newValue);
                        });
                      },
                    ),
                    TextFormField(
                        validator: (value) {
                          if (value!.contains(',')) {
                            value.replaceAll(RegExp(','), '.');
                          } else if (value.isEmpty || double.parse(value) < 1)
                            return 'Enter valid number';
                          return null;
                        },
                        decoration: InputDecoration(label: Text('Reps')),
                        keyboardType: TextInputType.number,
                        onSaved: (newValue) {
                          if (newValue!.contains(','))
                            newValue.replaceAll(RegExp(','), '.');
                          setState(() {
                            rps = double.parse(newValue);
                          });
                        }),
                  ],
                )),
            ElevatedButton(
                onPressed: () {
                  calculate();
                },
                child: Text('Calculate')),
            Text('Your 1RM is : $result')
          ],
        ),
      ),
    );
  }
}
