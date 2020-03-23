import 'package:firebase_auth/firebase_auth.dart';
import 'package:fliprkanban/widgets/button.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ForgotPassword extends StatefulWidget {
  static const String id = 'forgot';

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email, errorText = "";

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(
                "assets/logo_circle.png",
              ),
              width: 200.0,
              height: 200.0,
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              "Forgot your password?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              "Enter your registered email below to recieve password reset instruction",
              style: TextStyle(fontSize: 17, color: Colors.black38),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15.0,
            ),
            TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              decoration:
                  kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              onPressed: () async {
                //Implement login functionality.

                try {
                  resetPassword(email);

                  Navigator.pop(context);
                } catch (e) {
                  setState(() {
                    errorText = e.message;
                  });
                }
              },
              text: 'Send',
            ),
            Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
