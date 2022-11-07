// ignore_for_file: unused_import

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_app/screens/reset_password_screen.dart';
import 'package:training_app/auth.dart';
import '../auth.dart';

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _confirmationPasswordController =
      TextEditingController();
  String _email = '';
  String _password = '';
  String _confirmationPassword = '';
  bool _isLoading = false;
  bool _isValid = false;
  void _trySubmit() async {
    _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_isValid) {
      _formKey.currentState!.save();
      try {
        _isLoading = true;
        if (_isLogin) {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password);
        } else {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _email, password: _password);
        }
      } on PlatformException catch (err) {
        var message = 'An error occured';
        if (err.message != null) message = err.message!;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      } catch (err) {
        if (err is FirebaseAuthException) {
          switch (err.code) {
            case 'invalid-email':
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("There is no account with that e-mail")));
              break;
            case 'wrong-password':
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Invalid password")));
              break;
            case 'user-not-found':
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("User not found")));
              break;
            case 'user-disabled':
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("User is diasbled")));
              break;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text("Check your email and password, something is wrong")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text("There is a problem with logging, try again later")));
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget emailInputBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('E-mail',
            style: GoogleFonts.roboto(
                color: Theme.of(context).secondaryHeaderColor)),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.center,
          height: 50,
          decoration: BoxDecoration(
            color: Color.fromARGB(96, 255, 255, 255),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.roboto(color: Colors.black),
            validator: (value) {
              if (!value!.contains('@')) return 'Enter a valid email address';
              return null;
            },
            onSaved: ((newValue) {
              _email = newValue!;
            }),
            key: ValueKey('email'),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 13),
                border: InputBorder.none,
                hintText: "Enter your E-mail",
                // hintStyle:
                prefixIcon: Icon(
                  Icons.email,
                  color: Theme.of(context).secondaryHeaderColor,
                )),
          ),
        )
      ],
    );
  }

  Widget passwordInputBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Password',
            style: GoogleFonts.roboto(
                color: Theme.of(context).secondaryHeaderColor)),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.center,
          height: 50,
          decoration: BoxDecoration(
              color: Color.fromARGB(96, 255, 255, 255),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                )
              ]),
          child: TextFormField(
            style: GoogleFonts.roboto(color: Colors.black),
            obscureText: true,
            validator: (value) {
              if (value!.length < 8 && !_isLogin)
                return 'Password must have at least 8 letters';
              return null;
            },
            onSaved: ((newValue) {
              _password = newValue!;
            }),
            key: ValueKey('password'),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 13),
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: "Enter your password",
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).secondaryHeaderColor,
                )),
          ),
        )
      ],
    );
  }

  Widget passwordConfirmInputBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Confirm Password',
            style: GoogleFonts.roboto(
                color: Theme.of(context).secondaryHeaderColor)),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.center,
          height: 50,
          decoration: BoxDecoration(
              color: Color.fromARGB(96, 255, 255, 255),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                )
              ]),
          child: TextFormField(
            style: GoogleFonts.roboto(color: Colors.black),
            obscureText: true,
            controller: _confirmationPasswordController,
            validator: (value) {
              if (value != _confirmationPasswordController.text)
                return 'Enter the same password';
              return null;
            },
            onSaved: ((newValue) {
              _confirmationPassword = newValue!;
            }),
            key: ValueKey('confirmpassword'),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 13),
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: "Confirm password",
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).secondaryHeaderColor,
                )),
          ),
        )
      ],
    );
  }

  Widget logOrSignButton() {
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
        onPressed: () => _trySubmit(),
        label: Text(_isLogin ? 'Log In' : 'Sign in',
            style: GoogleFonts.roboto(
                color: Theme.of(context).secondaryHeaderColor)),
      ),
    );
  }

  Widget googleLoginButton() {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        icon: Icon(
          FontAwesomeIcons.google,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          onPrimary: Theme.of(context).secondaryHeaderColor,
          side: BorderSide(color: Theme.of(context).shadowColor, width: 0.3),
          shadowColor: Theme.of(context).secondaryHeaderColor,
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
        ),
        onPressed: () => AuthService().signup(),
        label: Text('Sign in with Google',
            style: GoogleFonts.roboto(
                color: Theme.of(context).colorScheme.secondary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewInsets.bottom,
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white54,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6.0, offset: Offset(0, 2))
          ],
        ),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          color: Colors.transparent,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    emailInputBox(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    passwordInputBox(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    if (!_isLogin) passwordConfirmInputBox(),
                    SizedBox(
                      height: 20,
                    ),
                    _isLoading
                        ? CircularProgressIndicator()
                        : logOrSignButton(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!_isLoading)
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                    _isLogin
                                        ? 'Create account'
                                        : 'I have an account',
                                    style: GoogleFonts.roboto(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                              ),
                            ),
                          if (_isLogin)
                            Expanded(
                              child: TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ResetPassword())),
                                  child: Text('Forgot password',
                                      style: GoogleFonts.roboto(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor))),
                            )
                        ]),
                    googleLoginButton()
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
