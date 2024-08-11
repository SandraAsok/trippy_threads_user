// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:trippy_threads/core/utilities.dart';
import 'package:trippy_threads/presentation/checkout/order_confirmed.dart';

class SingleCheckout extends StatefulWidget {
  const SingleCheckout({super.key});

  @override
  State<SingleCheckout> createState() => _SingleCheckoutState();
}

class _SingleCheckoutState extends State<SingleCheckout> {
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

  String quantity = "1";
  DateFormat outputFormat = DateFormat("dd/MM/yyyy");

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    List<String> items = [];
    getList() {
      for (int i = 1; i <= args['stock']; i++) {
        items.add(i.toString());
      }
    }

    getList();
    Future updateStock() async {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(args['product_id'])
            .update({
          'stock': args['stock'] - int.parse(quantity),
        });
      } catch (e) {
        log(e.toString());
      }
    }

    Future placeorder() async {
      try {
        await FirebaseFirestore.instance.collection('orders').add({
          'product_id': args['product_id'],
          'quantity': quantity,
          'image': args['image'],
          'product_name': args['product_name'],
          'description': args['description'],
          'details': args['details'],
          'totalPrice': paymentmethod == "razorpay"
              ? "${args['totalPrice']}"
              : "${int.parse(args['totalPrice']) * int.parse(quantity) + 50}",
          'size': args['size'],
          'address': args['address'],
          'saturday': isSaturday,
          'sunday': isSunday,
          'payment': paymentmethod,
          'placed_date': outputFormat.format(DateTime.now()),
          'userId': FirebaseAuth.instance.currentUser!.email,
        });
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
                            Navigator.pushNamed(context, 'singleaddress',
                                arguments: {
                                  'image': args['image'],
                                  'stock': args['stock'],
                                  'product_id': args['product_id'],
                                  'product_name': args['product_name'],
                                  'description': args['description'],
                                  'details': args['details'],
                                  'totalPrice': args['totalPrice'],
                                  'size': args['size'],
                                  'address': args['address'],
                                  'userId':
                                      FirebaseAuth.instance.currentUser!.email,
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
                          "Please select the quantity you needed ?",
                          style: GoogleFonts.abhayaLibre(
                              fontSize: 20, color: Colors.white),
                        ),
                        Row(
                          children: [
                            Spacer(),
                            Text(
                              "select here => ",
                              style: GoogleFonts.abhayaLibre(
                                  fontSize: 20, color: Colors.white),
                            ),
                            minwidth,
                            minwidth,
                            minwidth,
                            DropdownButton<String>(
                              dropdownColor: Colors.black,
                              iconEnabledColor: Colors.white,
                              value: quantity,
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
                                  quantity = newValue!;
                                });
                              },
                            ),
                            Spacer(),
                          ],
                        ),
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
                                    Spacer(),
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
                                    Spacer(),
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
                                    Spacer(),
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
                      payment = value!;
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
                      payment = value!;
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
                        ": ₹ ${int.parse(args['totalPrice']) * int.parse(quantity)} /-",
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
                            : ": ₹ ${int.parse(args['totalPrice']) * int.parse(quantity) + 50} /-",
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
                        if (payment == null) {
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
                        } else {
                          if (args['address'] !=
                              "Add+New+Address+for delivery") {
                            if (paymentmethod == "razorpay") {
                              checkout(int.parse(args['totalPrice']));
                            } else {
                              placeorder();
                              updateStock();
                            }
                          }
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
