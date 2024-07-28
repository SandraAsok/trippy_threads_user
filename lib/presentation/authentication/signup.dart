// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trippy_threads/presentation/authentication/signin.dart';
import 'package:trippy_threads/presentation/home/home.dart';
import 'package:trippy_threads/core/utilities.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

  Future signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: pass.text);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User Registered successfully")));
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setBool("islogged", true);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Spacer(),
          Text(
            "CREATE ACCOUNT",
            style: GoogleFonts.abhayaLibre(fontSize: 25, color: Colors.white),
          ),
          minheight,
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.abhayaLibre(color: Colors.white),
              decoration: InputDecoration(
                isDense: true,
                labelText: "Email",
                hintText: "Enter email address",
                hintStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                labelStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                errorText: errormessage.isEmpty ? null : errormessage,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.white)),
              ),
              onChanged: validateEmail,
            ),
          ),
          minheight,
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: pass,
              obscureText: _obscureText,
              keyboardType: TextInputType.visiblePassword,
              style: GoogleFonts.abhayaLibre(color: Colors.white),
              cursorColor: Colors.blueGrey,
              decoration: InputDecoration(
                  focusColor: Colors.blueGrey,
                  labelText: "Password",
                  hintText: "Enter a strong password",
                  isDense: true,
                  hintStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                  labelStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: togglePasswordVisibility,
                  )),
            ),
          ),
          minheight,
          minheight,
          ElevatedButton(
            onPressed: () {
              validateEmail(email.text);
              if (errormessage.isEmpty) {
                signup();
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                minimumSize: MaterialStateProperty.all(Size(200, 50))),
            child: Text(
              "Sign Up",
              style: GoogleFonts.abhayaLibre(fontSize: 25, color: Colors.white),
            ),
          ),
          minheight,
          minheight,
          Row(
            children: [
              Spacer(),
              Text(
                "Already a User? ",
                style: GoogleFonts.abhayaLibre(color: Colors.white),
              ),
              TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(),
                      )),
                  child: Text(
                    "Sign In",
                    style: GoogleFonts.abhayaLibre(
                        color: Colors.lightBlueAccent, fontSize: 18),
                  )),
              Spacer(),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
