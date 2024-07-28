// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trippy_threads/firebase_options.dart';
import 'package:trippy_threads/presentation/authentication/signup.dart';
import 'package:trippy_threads/presentation/checkout/add_address_cart.dart';
import 'package:trippy_threads/presentation/checkout/add_address_single.dart';
import 'package:trippy_threads/presentation/checkout/checkout.dart';
import 'package:trippy_threads/presentation/checkout/single_checkout.dart';
import 'package:trippy_threads/presentation/detail/product_detail.dart';
import 'package:trippy_threads/presentation/detail/saved_cart_detail.dart';
import 'package:trippy_threads/presentation/detail/saved_wishlist_detail.dart';
import 'package:trippy_threads/presentation/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Splash(),
    routes: {
      'viewdetails': (context) => ProductDetails(),
      'savedwishlist': (context) => SavedWishlistDetail(),
      'savedcart': (context) => SavedCartDetail(),
      'checkout': (context) => CheckoutScreen(),
      'singlecheckout': (context) => SingleCheckout(),
      'singleaddress': (context) => AddAddressSingle(),
      'cartaddress': (context) => AddAddressCart(),
    },
  ));
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    getloggedData().whenComplete(() {
      if (finalData == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(),
            ));
      }
    });
    super.initState();
  }

  bool? finalData;
  Future getloggedData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var obtainedData = preferences.getBool('islogged');
    setState(() {
      finalData = obtainedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/welcome.webp"),
          fit: BoxFit.fill,
        )),
        child: Column(
          children: [
            SizedBox(height: 200),
            Text(
              "Trippy\n Threads",
              style: GoogleFonts.abhayaLibre(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                  minimumSize: MaterialStateProperty.all(Size(200, 50))),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  )),
              child: Text(
                "GET STARTED",
                style:
                    GoogleFonts.abhayaLibre(fontSize: 25, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
