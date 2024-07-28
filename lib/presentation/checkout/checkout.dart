// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:trippy_threads/core/utilities.dart';
import 'package:trippy_threads/presentation/checkout/order_confirmed.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? payment;
  String? paymentmethod;
  bool isSaturday = false;
  bool isSunday = false;
  String additionalinstr = "";
  TextEditingController additional = TextEditingController();
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
  }

  void checkout(int price) async {
    var options = {
      'key': 'rzp_test_xMQq5wAwtsmsfE',
      'amount': 100 * price,
      'name': 'Trippy Threads PVT.Ltd',
      'description': 'Trippy Threads PVT.Ltd',
      'prefill': {
        'contact': '8075190230',
        'email': 'sandratrippythreads@razorpay.com',
      }
    };
    try {
      razorpay.open(options);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    Future placeorder() async {
      try {
        final userId = FirebaseAuth.instance.currentUser!.email;

        // Fetch cart items
        QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: userId)
            .get();
        for (var cartDoc in cartSnapshot.docs) {
          final cartItem = cartDoc.data() as Map<String, dynamic>;

          await FirebaseFirestore.instance.collection('orders').add({
            'product_id': cartItem['product_id'],
            'quantity': args['quantity'][cartDoc.id] ?? "1",
            'image': cartItem['image'],
            'product_name': cartItem['product_name'],
            'description': cartItem['description'],
            'details': cartItem['details'],
            'totalPrice': cartItem['price'],
            'size': cartItem['size'],
            'address': args['address'],
            'saturday': isSaturday,
            'sunday': isSunday,
            'payment': paymentmethod,
            'placed_date': DateTime.now(),
            'userId': FirebaseAuth.instance.currentUser!.email,
          });

          for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
            await doc.reference.delete();
          }
        }

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmed(),
            ));
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Something went wrong"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("check later?"))
              ],
            );
          },
        );
      }
    }

    void handlepaymentsuccess(PaymentSuccessResponse response) {
      log(response.toString());
      placeorder();
    }

    void handlepaymentError(PaymentFailureResponse response) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Something went wrong ! Please try again"),
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
    }

    void handleExternalWallet(ExternalWalletResponse response) {}

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlepaymentsuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlepaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                minheight,
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 5.5,
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        child: Center(
                          child: Text(
                            args['address'].split("+").join("\n"),
                            style: GoogleFonts.abhayaLibre(),
                          ),
                        ),
                      ),
                      IconButton.outlined(
                          onPressed: () {
                            Navigator.pushNamed(context, 'cartaddress',
                                arguments: {
                                  'Items': args['Items'],
                                  'totalPrice': args['totalPrice'],
                                  'address': args['address'],
                                });
                          },
                          icon: Icon(Icons.edit))
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "can you recieve deliveries on weekends?",
                          style: GoogleFonts.abhayaLibre(
                              fontSize: 20, color: Colors.white),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      fillColor: MaterialStateProperty.all(
                                          Colors.black),
                                      side: BorderSide(color: Colors.white),
                                      value: isSaturday,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isSaturday = value ?? false;
                                        });
                                      },
                                    ),
                                    Text(
                                      "Saturday",
                                      style: GoogleFonts.abhayaLibre(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      fillColor: MaterialStateProperty.all(
                                          Colors.black),
                                      side: BorderSide(color: Colors.white),
                                      value: isSunday,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          isSunday = value ?? false;
                                        });
                                      },
                                    ),
                                    Text(
                                      "Sunday",
                                      style: GoogleFonts.abhayaLibre(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "SELECT PAYMENT METHOD",
                    style: GoogleFonts.abhayaLibre(
                        color: Colors.white, fontSize: 17),
                  ),
                ),
                RadioListTile(
                  value: 'Pay with Razorpay',
                  title: Text(
                    "pay with Razorpay",
                    style: TextStyle(color: Colors.white),
                  ),
                  groupValue: payment,
                  onChanged: (value) {
                    setState(() {
                      payment = value;
                      paymentmethod = 'razorpay';
                    });
                  },
                ),
                RadioListTile(
                  value: 'Cash on Delivery',
                  title: Text(
                    "cash on Delivery",
                    style: TextStyle(color: Colors.white),
                  ),
                  groupValue: payment,
                  onChanged: (value) {
                    setState(() {
                      payment = value;
                      paymentmethod = 'cod';
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "ORDER SUMMARY",
                    style: GoogleFonts.abhayaLibre(
                        color: Colors.white, fontSize: 17),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        "Total Price",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 18, color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        ": ₹ ${args['totalPrice']} /-",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        "Delivery Charge",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 18,
                            color: paymentmethod == "razorpay"
                                ? Colors.white
                                : Colors.red),
                      ),
                      Spacer(),
                      Text(
                        paymentmethod == "razorpay" ? "₹ 0 /-" : ": ₹ 50 /-",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 18,
                            color: paymentmethod == "razorpay"
                                ? Colors.white
                                : Colors.red),
                      ),
                    ],
                  ),
                ),
                minheight,
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        "Order Total",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 18, color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        paymentmethod == "razorpay"
                            ? "₹ ${args['totalPrice']} /-"
                            : ": ₹ ${int.parse(args['totalPrice']) + 50} /-",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                minheight,
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (args['address'] != "Add+New+Address+for delivery") {
                          if (paymentmethod == "razorpay") {
                            checkout(int.parse(args['totalPrice']));
                          } else {
                            placeorder();
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Please select a payment method"),
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
                        }
                      },
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(300, 90)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueGrey)),
                      child: Text(
                        paymentmethod == "razorpay"
                            ? "Proceed To Pay"
                            : "Place Order",
                        style: GoogleFonts.abhayaLibre(
                            fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
