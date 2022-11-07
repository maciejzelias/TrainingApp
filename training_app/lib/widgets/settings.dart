import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training_app/themes.dart';
import 'package:training_app/widgets/1rm._dialog.dart';

import '../screens/configuration_screen.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({Key? key}) : super(key: key);

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  var _darkTheme = true;

  Widget logOutButton() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.login,
          color: Theme.of(context).secondaryHeaderColor,
          size: 20,
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).colorScheme.secondary,
          onPrimary: Theme.of(context).secondaryHeaderColor,
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
        ),
        onPressed: () => FirebaseAuth.instance.signOut(),
        label: Text('Log Out',
            style: GoogleFonts.roboto(
                color: Theme.of(context).secondaryHeaderColor)),
      ),
    );
  }

  Widget accountSettingsUI(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.roboto(
                color: Theme.of(context).secondaryHeaderColor,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == Themes.yellowBlack());
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: ListView(children: [
        Text(
          'Settings',
          style: GoogleFonts.roboto(
              color: Theme.of(context).secondaryHeaderColor, fontSize: 30),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Row(
          children: [
            Icon(
              Icons.person,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Account',
              style: GoogleFonts.roboto(
                  color: Theme.of(context).secondaryHeaderColor, fontSize: 25),
            ),
          ],
        ),
        Divider(
          height: 15,
          thickness: 3,
          color: Theme.of(context).primaryColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Change theme mode',
              style: GoogleFonts.roboto(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            Switch(
              activeColor: Theme.of(context).secondaryHeaderColor,
              value: _darkTheme,
              onChanged: (val) {
                setState(() {
                  _darkTheme = val;
                });
                onThemeChanged(val, themeNotifier);
              },
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Are you sure you want to change password?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          String? mail =
                              FirebaseAuth.instance.currentUser?.email;
                          if (mail != null) {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: mail);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('We\'ve sent you an email')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Something went wrong, try to sign out and use forgotten password feature')));
                          }
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Yes, send me reset password mail'),
                      )
                    ],
                  );
                });
          },
          child: accountSettingsUI('Change password'),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      content: Text(
                          'Are you sure you want to change configuration?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ConfigurationScreen())),
                          child: Text('Yes, take me to configuration screen'),
                        )
                      ],
                    ));
          },
          child: accountSettingsUI('Change configuration'),
        ),
        accountSettingsUI('Language'),
        accountSettingsUI('Privacy and security'),
        GestureDetector(
          child: accountSettingsUI('Estimate 1RM'),
          onTap: () {
            showDialog(context: context, builder: (context) => RmDialog());
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Row(
          children: [
            Icon(
              Icons.person,
              color: Theme.of(context).secondaryHeaderColor,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              'Notifications',
              style: GoogleFonts.roboto(
                  color: Theme.of(context).secondaryHeaderColor, fontSize: 25),
            ),
          ],
        ),
        Divider(
          height: 15,
          thickness: 3,
          color: Theme.of(context).primaryColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'News',
              style: GoogleFonts.roboto(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            Switch(
              activeColor: Theme.of(context).secondaryHeaderColor,
              value: true,
              onChanged: (bool value) {},
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: logOutButton(),
        )
      ]),
    );
  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(Themes.yellowBlack())
        : themeNotifier.setTheme(Themes.energyTheme());
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }
}
