// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trippy_threads/core/utilities.dart';
import 'package:trippy_threads/main.dart';
import 'package:trippy_threads/presentation/cart/cart.dart';
import 'package:trippy_threads/presentation/detail/productlist.dart';
import 'package:trippy_threads/presentation/orders/orders.dart';
import 'package:trippy_threads/presentation/wishlist/wishlist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imgList = [
    "assets/slider1.jpeg",
    "assets/slider2.jpeg",
    "assets/slider3.jpeg",
    "assets/slider4.jpeg",
  ];

  List gridimg = [];

  List gridtext = [];

  Future fetchcoverpics() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      List values = querySnapshot.docs.map((doc) => doc['cover']).toList();
      setState(() {
        gridimg = values;
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  Future fetchcovertext() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      List values = querySnapshot.docs.map((doc) => doc['category']).toList();
      setState(() {
        gridtext = values;
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchcoverpics();
    fetchcovertext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: iconcolor),
        backgroundColor: bgcolor,
        // centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "TRIPY\t\t\tTHREADS",
            style: GoogleFonts.acme(fontSize: 25, color: fontcolor),
          ),
        ),
      ),
      endDrawer: Drawer(
        backgroundColor: bgcolor,
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CartScreen()));
              },
              leading: Icon(Icons.shopping_cart, color: iconcolor, size: 20),
              title: Text("Cart",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WishlistScreen()));
              },
              leading: Icon(Icons.favorite, color: iconcolor, size: 20),
              title: Text("Wishlist",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OrderScreen()));
              },
              leading: Icon(Icons.shopping_bag, color: iconcolor, size: 20),
              title: Text("Orders",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
            Divider(),
            Divider(),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.privacy_tip, color: iconcolor, size: 20),
              title: Text("Privacy Policy",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.policy, color: iconcolor, size: 20),
              title: Text("Terms and Conditions",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.remove_red_eye, color: iconcolor, size: 20),
              title: Text("About",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
            Divider(),
            Divider(),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.settings, color: iconcolor),
              title:
                  Text("Settings", style: GoogleFonts.acme(color: fontcolor)),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.help_center, color: iconcolor, size: 20),
              title: Text("Help Center",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
            ListTile(
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  final SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.setBool('islogged', false);
                  setState(() {});
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomeScreen(),
                      ));
                } catch (e) {
                  log('$e');
                }
              },
              leading: Icon(Icons.logout, color: iconcolor, size: 20),
              title: Text("Log out",
                  style: GoogleFonts.acme(color: fontcolor, fontSize: 15)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            minheight,
            minheight,
            CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: imgList
                  .map((item) => Container(
                        width: 300,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(item), fit: BoxFit.cover)),
                      ))
                  .toList(),
            ),
            minheight,
            minheight,
            Text(
              "Unleash Your Inner Psyche:\n \t Wear the Vibe",
              style: GoogleFonts.acme(color: fontcolor, fontSize: 20),
            ),
            minheight,
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: GridView.builder(
                  itemCount: gridimg.length,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListScreen(
                              item: gridtext[index],
                            ),
                          )),
                      child: Container(
                        height: 350,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(gridimg[index]))),
                        child: Center(
                          child: Text(
                            gridtext[index].toString().toUpperCase(),
                            style: GoogleFonts.acme(
                                fontSize: 25, color: fontcolor),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
