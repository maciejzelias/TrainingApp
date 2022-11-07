import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:training_app/screens/configuration_screen.dart';
import 'package:training_app/screens/home_screen.dart' show HomeScreen;

class Screen1 extends StatefulWidget {
  Screen1({Key? key}) : super(key: key);

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  bool isConfigured = false;
  bool doneJob = false;
  Timer? timer;
  final user = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    fethcingDocument();
    timer =
        Timer.periodic(Duration(milliseconds: 10), (_) => fethcingDocument());
    super.initState();
  }

  void fethcingDocument() async {
    var doc =
        await FirebaseFirestore.instance.collection('users').doc(user).get();
    Map<String, dynamic>? data = await doc.data();
    setState(() {
      isConfigured = data!['isConfigured'];
      doneJob = true;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<bool> checkConfigure() async {
    var doc =
        await FirebaseFirestore.instance.collection('users').doc(user).get();
    Map<String, dynamic>? data = await doc.data();
    return data!['isConfigured'];
  }

  @override
  Widget build(BuildContext context) => doneJob
      ? isConfigured
          ? HomeScreen()
          : ConfigurationScreen()
      : Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
}
