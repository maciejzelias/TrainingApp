import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _controller = TextEditingController();

  Widget resetPasswordButton() {
    return MaterialButton(
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30)),
      onPressed: () async {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _controller.text);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('We\'ve sent you an email')));
      },
      child: Text('Reset Password'),
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget resetPasswordEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).secondaryHeaderColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'e-mail',
            fillColor: Colors.grey[200],
            filled: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).secondaryHeaderColor),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text('Reset your password',
            style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
        elevation: 5,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Type your email to reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          resetPasswordEmailField(),
          SizedBox(
            height: 10,
          ),
          resetPasswordButton()
        ],
      ),
    );
  }
}
