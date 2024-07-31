// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_threads/core/utilities.dart';
import 'package:trippy_threads/presentation/wishlist/wishlist.dart';

class SavedCartDetail extends StatefulWidget {
  const SavedCartDetail({super.key});

  @override
  State<SavedCartDetail> createState() => _SavedCartDetailState();
}

class _SavedCartDetailState extends State<SavedCartDetail> {
  String selectedSize = '';
  bool isCart = false;
  bool isWish = false;

  final List<String> sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  List addresslist = [];
  Future fetchAddress() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('address')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();
      List address = querySnapshot.docs.map((doc) => doc['address']).toList();
      setState(() {
        addresslist = address;
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    fetchAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    selectedSize = args['size'];

    checkCartstate() async {
      final cartitems = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .where('product_id', isEqualTo: args['product_id'])
          .get();
      if (cartitems.docs.isNotEmpty) {
        setState(() {
          isCart = true;
        });
      }
    }

    checkWishliststate() async {
      final wishlistitems = await FirebaseFirestore.instance
          .collection('wishlist')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .where('product_id', isEqualTo: args['product_id'])
          .get();
      if (wishlistitems.docs.isNotEmpty) {
        setState(() {
          isWish = true;
        });
      }
    }

    Future addtoCart() async {
      try {
        await FirebaseFirestore.instance.collection('cart').add({
          'image': args['image'],
          'product_id': args['product_id'],
          'product_name': args['product_name'],
          'description': args['description'],
          'details': args['details'],
          'price': int.parse(args['price']),
          'size': selectedSize,
          'userId': FirebaseAuth.instance.currentUser!.email,
        });
        setState(() {
          isCart = true;
        });
      } catch (e) {
        log(e.toString());
      }
    }

    Future addtoWishlist() async {
      try {
        await FirebaseFirestore.instance.collection('wishlist').add({
          'image': args['image'],
          'product_id': args['product_id'],
          'product_name': args['product_name'],
          'description': args['description'],
          'details': args['details'],
          'price': args['price'],
          'size': selectedSize,
          'userId': FirebaseAuth.instance.currentUser!.email,
        });
        setState(() {
          isWish = true;
        });
      } catch (e) {
        log(e.toString());
      }
    }

    checkCartstate();
    checkWishliststate();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            minheight,
            minheight,
            Stack(
              alignment: Alignment.topRight,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 450.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: Duration(seconds: 1),
                    viewportFraction: 0.8,
                  ),
                  items: args['image']
                      .map<Widget>((item) => Container(
                            width: 300,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(item),
                                    fit: BoxFit.cover)),
                          ))
                      .toList(),
                ),
                IconButton.filled(
                    highlightColor: Colors.blueGrey,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.black),
                        side: MaterialStateProperty.all(
                            BorderSide(color: Colors.white))),
                    onPressed: () async {
                      if (isWish == false) {
                        if (selectedSize.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Please select a size"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Go back"))
                                ],
                              );
                            },
                          );
                        } else {
                          addtoWishlist();
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WishlistScreen()));
                      }
                    },
                    icon: Icon(isWish ? Icons.favorite : Icons.favorite_border))
              ],
            ),
            minheight,
            Text(
              args['product_name'],
              style: GoogleFonts.abhayaLibre(
                color: Colors.greenAccent,
                fontSize: 22,
              ),
            ),
            minheight,
            Text(
              args['description'],
              style: GoogleFonts.abhayaLibre(color: Colors.white),
            ),
            minheight,
            Row(children: [
              Spacer(),
              Text(
                "Price : ",
                style: GoogleFonts.abhayaLibre(color: Colors.white),
              ),
              Text(
                "₹ ${args['price']}/-",
                style: GoogleFonts.abhayaLibre(color: Colors.lightBlueAccent),
              ),
              Spacer(),
            ]),
            minheight,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: sizes.map((size) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(60, 60)),
                      shape: MaterialStateProperty.all(CircleBorder(
                          side: BorderSide(color: Colors.white, width: 2.0))),
                      backgroundColor: MaterialStateProperty.all(
                          selectedSize == size
                              ? Colors.blueGrey
                              : Colors.black),
                    ),
                    child: Text(
                      size,
                      style: GoogleFonts.abhayaLibre(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
            minheight,
            Text(
              "Product Details : ",
              style: GoogleFonts.abhayaLibre(color: Colors.greenAccent),
            ),
            minheight,
            Text(
              args['details'].split("+").join("\n"),
              style: GoogleFonts.abhayaLibre(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            minheight,
          ],
        ),
      ),
      bottomSheet: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.black),
        child: Row(
          children: [
            Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
              ),
              onPressed: () async {
                if (isCart == false) {
                  if (selectedSize.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text("Please select a size"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Go back"))
                          ],
                        );
                      },
                    );
                  } else {
                    addtoCart();
                  }
                } else {
                  await FirebaseFirestore.instance
                      .collection('cart')
                      .doc(args['cartId'])
                      .delete();
                  setState(() {
                    isCart = false;
                  });
                }
              },
              child: Text(
                isCart ? "Remove" : "Add to Cart",
                style:
                    GoogleFonts.abhayaLibre(fontSize: 18, color: Colors.white),
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey; // Disabled color
                    }
                    return Colors.blue; // Enabled color
                  },
                ),
              ),
              onPressed: args['stock'] == 0
                  ? null
                  : () {
                      log(args.toString());
                      Navigator.pushNamed(context, 'singlecheckout',
                          arguments: {
                            'image': args['image'],
                            'product_id': args['product_id'],
                            'product_name': args['product_name'],
                            'description': args['description'],
                            'details': args['details'],
                            'totalPrice': args['price'].toString(),
                            'size': selectedSize,
                            'address': addresslist.isEmpty
                                ? "Add+New+Address+for delivery"
                                : addresslist[0],
                            'userId': FirebaseAuth.instance.currentUser!.email,
                          });
                    },
              child: Text(
                args['stock'] == 0 ? "Out of Stock" : "BUY NOW",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
