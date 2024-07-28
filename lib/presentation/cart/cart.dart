// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_threads/core/utilities.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, String> selectedItems = {};
  List<String> items = ['1', '2', '3', '4', '5'];
  int total = 0;
  String? productId;
  String? name;
  String? description;
  String? details;
  List? image;
  String? product_price;
  String? size;

  Future fetchPrice() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();
      List prices = querySnapshot.docs.map((doc) => doc['price']).toList();
      setState(() {
        total = 0;
        for (var item in prices) {
          total += int.parse(item.toString());
        }
      });
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

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

  List saturdaylist = [];
  List sundaylist = [];

  @override
  void initState() {
    fetchPrice();
    fetchAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text(
          "Cart & Collections",
          style: GoogleFonts.abhayaLibre(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userId',
                isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            log(snapshot.error.toString());
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final snap = snapshot.data!.docs[index];
                    String itemId = snap.id;

                    int quantity = int.parse(selectedItems[itemId] ?? '1');
                    int price = snap['price'];
                    productId = snap['product_id'];
                    name = snap['product_name'];
                    description = snap['description'];
                    details = snap['details'];
                    image = snap['image'];
                    size = snap['size'];

                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, 'savedcart',
                                  arguments: {
                                    'product_id': snap['product_id'],
                                    'product_name': snap['product_name'],
                                    'description': snap['description'],
                                    'details': snap['details'],
                                    'image': snap['image'],
                                    'price': snap['price'],
                                    'size': snap['size'],
                                    'cartId': snap.id,
                                  });
                            },
                            child: Container(
                              height: 100,
                              width: 500,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(snap['image'][0]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: SizedBox(
                                      width: 200,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snap['product_name'],
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "₹ ${price * quantity}",
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  minwidth,
                                  minwidth,
                                  DropdownButton<String>(
                                    dropdownColor: Colors.black,
                                    iconEnabledColor: Colors.white,
                                    value: selectedItems[itemId] ?? "1",
                                    style: GoogleFonts.abhayaLibre(
                                        fontSize: 25, color: Colors.white),
                                    items: items.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        int previousQuantity = int.parse(
                                            selectedItems[itemId] ?? '1');
                                        int newQuantity = int.parse(newValue!);

                                        total -= price * previousQuantity;
                                        total += price * newQuantity;

                                        selectedItems[itemId] = newValue;
                                      });
                                    },
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
                                    "Do you want to remove this from the cart?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(snap.id)
                                          .delete();
                                      Navigator.pop(context);
                                    },
                                    child: Text("Yes"),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BottomSheet(
                  onClosing: () {},
                  builder: (context) => SizedBox(
                    height: 90,
                    child: ListTile(
                      title: Text(
                        "Total : ",
                        style: GoogleFonts.abhayaLibre(fontSize: 20),
                      ),
                      subtitle: Text(
                        "₹ ${total.toStringAsFixed(2)} /-",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      trailing: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueGrey),
                          minimumSize: MaterialStateProperty.all(Size(100, 50)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, 'checkout', arguments: {
                            'quantity': selectedItems,
                            'totalPrice': total.toString(),
                            'address': addresslist.isEmpty
                                ? "Add+New+Address+for delivery"
                                : addresslist[0],
                          });
                        },
                        child: Text(
                          "CHECKOUT",
                          style: GoogleFonts.abhayaLibre(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}