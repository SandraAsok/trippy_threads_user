// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool isWish = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Text(
            "Wishlist & Collections",
            style: GoogleFonts.abhayaLibre(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('wishlist')
                .where('userId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                log(snapshot.error.toString());
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final snap = snapshot.data!.docs[index];
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'savedwishlist',
                                arguments: {
                                  'product_id': snap['product_id'],
                                  'product_name': snap['product_name'],
                                  'description': snap['description'],
                                  'details': snap['details'],
                                  'image': snap['image'],
                                  'price': snap['price'],
                                  'size': snap['size'],
                                  'wishId': snap.id,
                                });
                          },
                          child: Container(
                            height: 100,
                            width: 500,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(25)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                snap['image'][0]))),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: SizedBox(
                                    width: 200,
                                    child: Column(
                                      children: [
                                        Text(
                                          snap['product_name'],
                                          style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        // Text(
                                        //   "₹ ${snap['price']}/-",
                                        //   style: TextStyle(
                                        //       overflow: TextOverflow.ellipsis,
                                        //       color: Colors.white,
                                        //       fontSize: 20),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton.filled(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              side: MaterialStateProperty.all(
                                  BorderSide(color: Colors.white))),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Text(
                                    "Do you want to remove this from favourites ?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("No")),
                                  TextButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('wishlist')
                                            .doc(snap.id)
                                            .delete();
                                      },
                                      child: Text("Yes"))
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.white,
                          )),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }
}
