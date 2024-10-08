import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trippy_threads/presentation/authentication/forgot_password.dart';
import 'package:trippy_threads/presentation/home/home.dart';
import 'package:trippy_threads/core/utilities.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  String errormessage = "";

  validateEmail(String emailid) {
    const pattern =
        r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]{2,}$';
    final RegExp regExp = RegExp(pattern);
    if (emailid.isEmpty) {
      setState(() {
        errormessage = "Enter an email address";
      });
    } else if (!regExp.hasMatch(emailid)) {
      setState(() {
        errormessage = "Enter valid email id";
      });
    } else {
      setState(() {
        errormessage = "";
      });
    }
  }

  bool _obscureText = true;

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future usersignin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.text, password: pass.text);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("logged in successfully")));
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setBool("islogged", true);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert !"),
          content: Text("supplied credentials are\n incorrect"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("ok"))
          ],
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Password reset link sent to ${email.text}"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      log("Error resetting password: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: Unable to send reset email"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Spacer(),
            Text(
              "We Missed You",
              style: GoogleFonts.acme(fontSize: 25, color: fontcolor),
            ),
            minheight,
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: email,
                style: GoogleFonts.acme(color: fontcolor),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: "Email",
                  hintText: "Enter email address",
                  hintStyle: GoogleFonts.acme(color: fontcolor),
                  labelStyle: GoogleFonts.acme(color: fontcolor),
                  errorText: errormessage.isEmpty ? null : errormessage,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: buttonbg)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: buttonbg)),
                ),
                onChanged: validateEmail,
              ),
            ),
            minheight,
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: pass,
                style: GoogleFonts.acme(color: fontcolor),
                obscureText: _obscureText,
                keyboardType: TextInputType.visiblePassword,
                cursorColor: Colors.blueGrey,
                decoration: InputDecoration(
                    focusColor: Colors.blueGrey,
                    labelText: "Password",
                    hintText: "Enter a strong password",
                    isDense: true,
                    hintStyle: GoogleFonts.acme(color: fontcolor),
                    labelStyle: GoogleFonts.acme(color: fontcolor),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: buttonbg)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: buttonbg)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: togglePasswordVisibility,
                    )),
              ),
            ),
            minheight,
            TextButton(
              onPressed: _resetPassword,
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: Colors.white),
              ),
            ),
            minheight,
            Row(
              children: [
                TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPassword(),
                        )),
                    child: Text(
                      "forgot password?",
                      style: GoogleFonts.acme(color: Colors.lightBlueAccent),
                    )),
              ],
            ),
            minheight,
            minheight,
            MaterialButton(
              onPressed: () {
                validateEmail(email.text);
                if (errormessage.isEmpty) {
                  usersignin();
                }
              },
              color: buttonbg,
              child: Text(
                "Sign In",
                style: GoogleFonts.acme(fontSize: 25, color: buttonfont),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
