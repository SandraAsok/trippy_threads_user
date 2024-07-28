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
              style: GoogleFonts.abhayaLibre(fontSize: 25, color: Colors.white),
            ),
            minheight,
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: email,
                style: GoogleFonts.abhayaLibre(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: "Email",
                  hintText: "Enter email address",
                  hintStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                  labelStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                  errorText: errormessage.isEmpty ? null : errormessage,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueGrey)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.blueGrey)),
                ),
                onChanged: validateEmail,
              ),
            ),
            minheight,
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: pass,
                style: GoogleFonts.abhayaLibre(color: Colors.white),
                obscureText: _obscureText,
                keyboardType: TextInputType.visiblePassword,
                cursorColor: Colors.blueGrey,
                decoration: InputDecoration(
                    focusColor: Colors.blueGrey,
                    labelText: "Password",
                    hintText: "Enter a strong password",
                    isDense: true,
                    hintStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                    labelStyle: GoogleFonts.abhayaLibre(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: togglePasswordVisibility,
                    )),
              ),
            ),
            minheight,
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
                      style: GoogleFonts.abhayaLibre(
                          color: Colors.lightBlueAccent),
                    )),
              ],
            ),
            minheight,
            minheight,
            ElevatedButton(
              onPressed: () {
                validateEmail(email.text);
                if (errormessage.isEmpty) {
                  usersignin();
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                  minimumSize: MaterialStateProperty.all(Size(200, 50))),
              child: Text(
                "Sign In",
                style:
                    GoogleFonts.abhayaLibre(fontSize: 25, color: Colors.white),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
