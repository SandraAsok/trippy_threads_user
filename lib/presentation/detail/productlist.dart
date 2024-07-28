// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_threads/core/utilities.dart';

class ProductListScreen extends StatefulWidget {
  final String item;
  const ProductListScreen({super.key, required this.item});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List categorypic = [
    "assets/black.jpg",
    "assets/white.jpeg",
    "assets/multicolor.jpeg",
    "assets/spiritual.jpeg",
  ];
  final List categorytext = [
    "black",
    "white",
    "multicolor",
    "spiritual",
  ];

  String? color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text(
          widget.item.toUpperCase(),
          style: GoogleFonts.abhayaLibre(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categorypic.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          color = categorytext[index];
                        });
                      },
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage(categorypic[index]))),
                      ),
                    ),
                  );
                },
              ),
            ),
            minheight,
            minheight,
            minheight,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 2,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('category', isEqualTo: widget.item)
                        .where('colorcode', isEqualTo: color)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LinearProgressIndicator(
                          backgroundColor: Colors.black,
                          color: Colors.black,
                        );
                      } else if (snapshot.hasError) {
                        log("Errorrrrr ::: ${snapshot.error}");
                      }
                      return GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 50),
                        itemBuilder: (context, index) {
                          final snap = snapshot.data!.docs[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, 'viewdetails',
                                  arguments: {
                                    'product_id': snap.id,
                                    'product_name': snap['product_name'],
                                    'description': snap['description'],
                                    'details': snap['details'],
                                    'price': snap['price'],
                                    'category': snap['category'],
                                    'colorcode': snap['colorcode'],
                                    'image': snap['image'],
                                  });
                            },
                            child: Container(
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        aspectRatio: 2,
                                        animateToClosest: true,
                                        disableCenter: true,
                                        enlargeCenterPage: true,
                                        enableInfiniteScroll: true,
                                        autoPlay: true,
                                      ),
                                      items: snap['image']
                                          .map<Widget>((item) => Center(
                                                child: Image.network(item,
                                                    fit: BoxFit.fill,
                                                    width: 140),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      Spacer(),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          snap['product_name'],
                                          style: TextStyle(
                                              fontFamily: GoogleFonts
                                                  .abhayaLibre
                                                  .toString(),
                                              color: Colors.white,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "₹ ${snap['price']}/-",
                                        style: GoogleFonts.abhayaLibre(
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
