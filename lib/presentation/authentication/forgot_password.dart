import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_threads/core/utilities.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgcolor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: email,
                cursorColor: Colors.blueGrey,
                decoration: InputDecoration(
                  focusColor: Colors.blueGrey,
                  labelText: "Verification email",
                  hintText: "Enter Verification email",
                  isDense: true,
                  hintStyle: GoogleFonts.acme(color: fontcolor),
                  labelStyle: GoogleFonts.acme(color: fontcolor),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: buttonbg)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: buttonbg)),
                ),
              ),
            ),
            minheight,
            minheight,
            MaterialButton(
              onPressed: () {},
              color: buttonbg,
              child: Text(
                "Submit",
                style: GoogleFonts.acme(fontSize: 25, color: buttonfont),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
