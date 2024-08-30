import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:trippy_threads/core/utilities.dart';
import 'package:trippy_threads/presentation/home/home.dart';

class OrderConfirmed extends StatefulWidget {
  const OrderConfirmed({super.key});

  @override
  State<OrderConfirmed> createState() => _OrderConfirmedState();
}

class _OrderConfirmedState extends State<OrderConfirmed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Lottie.asset('assets/animation.json'),
          ),
          minheight,
          minheight,
          minheight,
          MaterialButton(
            animationDuration: Duration(seconds: 10),
            autofocus: true,
            color: Colors.blueGrey,
            height: 60,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ));
            },
            child: Text(
              "Continue Shopping",
              style: GoogleFonts.acme(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
