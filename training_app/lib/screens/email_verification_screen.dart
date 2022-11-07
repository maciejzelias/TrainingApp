// import 'dart:html';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:training_app/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({Key? key}) : super(key: key);

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  Timer? timer;
  bool canSendEmail = true;
  bool isEmailVerified = false;
  bool goToScreen = false;
  bool doneJob = false;
  bool isConfigured = false;
  var id = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    super.initState();
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(Duration(seconds: 5), (_) => checkMail());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkMail() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .set({'isConfigured': false});
      await FirebaseFirestore.instance
          .collection('users/$id/templates')
          .add({});
      await FirebaseFirestore.instance.collection('users/$id/history').add({});
      await FirebaseFirestore.instance
          .collection('users/$id/measures')
          .doc('chest')
          .set({'type': 'measure'});
      await FirebaseFirestore.instance
          .collection('users/$id/measures')
          .doc('arm')
          .set({'type': 'measure'});
      await FirebaseFirestore.instance
          .collection('users/$id/measures')
          .doc('weight')
          .set({'type': 'measure'});

      await FirebaseFirestore.instance
          .collection('users/$id/exercises')
          .doc('chest')
          .set({'type': 'exercises'});
      await FirebaseFirestore.instance
          .collection('users/$id/exercises')
          .doc('arms')
          .set({'type': 'exercises'});
      await FirebaseFirestore.instance
          .collection('users/$id/exercises')
          .doc('back')
          .set({'type': 'exercises'});
      await FirebaseFirestore.instance
          .collection('users/$id/exercises')
          .doc('legs')
          .set({'type': 'exercises'});
      await FirebaseFirestore.instance
          .collection('users/$id/exercises')
          .doc('core')
          .set({'type': 'exercises'});
      await FirebaseFirestore.instance
          .collection('users/$id/exercises')
          .doc('shoulders')
          .set({'type': 'exercises'});

      await FirebaseFirestore.instance
          .collection('users/$id/exercisesPerformed')
          .add({});
      timer?.cancel();
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? Screen1()
      : SafeArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/dzikbialy1.png"),
                          fit: BoxFit.contain),
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(90),
                          bottomRight: const Radius.circular(90)),
                      boxShadow: [
                        new BoxShadow(
                            color: Theme.of(context).shadowColor,
                            blurRadius: 15.0)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.all(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Theme.of(context).colorScheme.secondary,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            canSendEmail
                                ? sendVerificationEmail()
                                : ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'We\'ve already sent you 2 emails')));
                            setState(() {
                              canSendEmail = false;
                            });
                          },
                          icon: Icon(
                            Icons.send,
                            size: 24.0,
                          ),
                          label: const Text('Resend email verification'),
                          style: ElevatedButton.styleFrom(
                            // elevation: 20,
                            primary: Theme.of(context).colorScheme.secondary,
                            onPrimary: Theme.of(context).secondaryHeaderColor,
                            side: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor,
                                width: 0.3),
                            shadowColor: Theme.of(context).secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      CircularProgressIndicator(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Text("You need to verify your e-mail...",
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                    ],
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              icon: Icon(
                Icons.logout_outlined,
                size: 15,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              label: Text(
                'Cancel \nRegistration',
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
              ),
              onPressed: () async =>
                  await FirebaseAuth.instance.currentUser!.delete(),
            ),
          ),
        );
}
