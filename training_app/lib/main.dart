// import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training_app/screens/authentication_screen.dart';
import 'package:training_app/screens/email_verification_screen.dart';
import 'package:training_app/screens/home_screen.dart' show trainingScreenNotifier;
import 'firebase_options.dart';
import 'themes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initialization();

  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(
              darkModeOn ? Themes.yellowBlack() : Themes.energyTheme()),
        ),
        ChangeNotifierProvider(
          create: (_) => trainingScreenNotifier(),
        )
      ],
      child: MyApp(),
    ));
  });
}

void initialization() async {
  await Future.delayed(const Duration(seconds: 0));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return WillPopScope(
      child: MaterialApp(
        title: 'Training App',
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return EmailVerification();
            }
            return AuthenticationScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
      ),
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
    );
  }
}
