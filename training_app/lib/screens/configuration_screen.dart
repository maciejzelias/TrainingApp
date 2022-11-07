import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  double spaceBetween = 0.02;
  late String nick;
  late String gender;
  late int weight;
  late int height;
  bool _isLoading = false;
  late TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> items = ['Male', 'Female'];
  bool _isTaken = false;

  Future<bool> _checkNick(String nick) async {
    bool result = false;
    QuerySnapshot<Map<String, dynamic>> stream =
        await FirebaseFirestore.instance.collection('users').get();
    stream.docs.forEach((element) {
      if (element.data()['nickname'] == nick) result = true;
    });
    return result;
  }

  void trySubmit() async {
    FocusScope.of(context).unfocus();
    _isTaken = await _checkNick(controller.text);
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        var uid = await FirebaseAuth.instance.currentUser!.uid;
        //ogarnac roznice miedzy set a update
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'nickname': nick,
          'height': height,
          'weight': weight,
          'gender': gender,
          'isConfigured': true,
        }, SetOptions(merge: true));
      } catch (err) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Something went wrong")));
      }
      setState(() {
        _isLoading = false;
      });
    } else
      print('dupa zbita');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Theme.of(context).primaryColor,
            body: Stack(children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0578,
                      ),
                      Text(
                        'Basic',
                        style: GoogleFonts.publicSans(
                            fontSize: 35, color: Colors.white),
                      ),
                      Text(
                        'Informations',
                        style: GoogleFonts.publicSans(
                            fontSize: 50, color: Colors.white),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black,
                          Theme.of(context).colorScheme.secondary
                        ]),
                    borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(90),
                        bottomRight: const Radius.circular(90)),
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: new ClipRect(
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 10, sigmaY: 10.0),
                      child: new Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.6,
                        decoration: new BoxDecoration(
                            color: Colors.white.withOpacity(0.1)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.01,
                                right:
                                    MediaQuery.of(context).size.width * 0.01),
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            cursorColor: Colors.white,
                                            style:
                                                TextStyle(color: Colors.white),
                                            controller: controller,
                                            onSaved: (newValue) =>
                                                {nick = newValue!},
                                            validator: ((value) {
                                              if (_isTaken)
                                                return 'This nick is already taken';
                                              else if (value!.isEmpty)
                                                return 'Enter a nickname';
                                              return null;
                                            }),
                                            decoration: InputDecoration(
                                                labelText: 'Nick'),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                spaceBetween,
                                          ),
                                          TextFormField(
                                            cursorColor: Colors.white,
                                            style:
                                                TextStyle(color: Colors.white),
                                            validator: (value) {
                                              int value1 = int.parse(value!);
                                              if (value1 > 300 || value1 < 30)
                                                return 'Please enter your real weight';
                                              else if (value.length == 0)
                                                return 'Enter your weight';
                                              return null;
                                            },
                                            onSaved: (newValue) {
                                              weight = int.parse(newValue!);
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Weight'),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                spaceBetween,
                                          ),
                                          TextFormField(
                                            cursorColor: Colors.white,
                                            style:
                                                TextStyle(color: Colors.white),
                                            validator: (value) {
                                              if (value!.isEmpty)
                                                return 'Enter your height';
                                              int value1 = int.parse(value);
                                              if (value1 > 230 || value1 < 50)
                                                return 'Please enter your real height';
                                              return null;
                                            },
                                            onSaved: (newValue) {
                                              height = int.parse(newValue!);
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Height'),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                spaceBetween,
                                          ),
                                          DropdownButtonFormField(
                                              dropdownColor: Colors.black,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              validator: (value) {
                                                if (value == null)
                                                  return 'Pick a gender';
                                                return null;
                                              },
                                              onSaved: (newValue) {
                                                gender = newValue as String;
                                              },
                                              decoration: InputDecoration(
                                                  labelText: 'Gender'),
                                              items: items.map((String items) {
                                                return DropdownMenuItem(
                                                  value: items,
                                                  child: Text(items),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {}),
                                          _isLoading
                                              ? CircularProgressIndicator()
                                              : ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty.all(
                                                              Theme.of(context)
                                                                  .primaryColor),
                                                      shape: MaterialStateProperty.all<
                                                              RoundedRectangleBorder>(
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      18.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .white)))),
                                                  onPressed: () => trySubmit(),
                                                  child: Text('Submit'))
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ])));
  }
}
