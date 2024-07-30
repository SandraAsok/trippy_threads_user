// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trippy_threads/core/utilities.dart';
import 'package:trippy_threads/presentation/orders/timeline_tile.dart';

class OrderDetail extends StatefulWidget {
  final String orderId;
  const OrderDetail({super.key, required this.orderId});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          title: Text(
            "Order Details",
            style: GoogleFonts.abhayaLibre(color: Colors.white),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .doc(widget.orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                log(snapshot.error.toString());
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              final snap = snapshot.data!.data();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      minheight,
                      Text(
                        "Order ID : ${widget.orderId}",
                        style:
                            GoogleFonts.abhayaLibre(color: Colors.greenAccent),
                      ),
                      minheight,
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snap?['product_name'],
                                style: GoogleFonts.abhayaLibre(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              minheight,
                              Text(
                                snap?['description'],
                                style: GoogleFonts.abhayaLibre(
                                    color: Colors.white),
                              ),
                              minheight,
                              Text(
                                "₹ ${snap?['totalPrice']} /-",
                                style: GoogleFonts.abhayaLibre(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(snap?['image'][0])),
                            ),
                          ),
                        ],
                      ),
                      minheight,
                      minheight,
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              TimelineTileWidget(
                                isFirst: true,
                                isLast: false,
                                isPast: true,
                                text:
                                    'order placed : \n${DateFormat('dd/MM/yyyy').format(snap?['placed_date'].toDate())}',
                              ),
                              TimelineTileWidget(
                                isFirst: false,
                                isLast: false,
                                isPast: true,
                                text: 'Shipped',
                              ),
                              TimelineTileWidget(
                                isFirst: false,
                                isLast: false,
                                isPast: true,
                                text: 'Reached nearest hub',
                              ),
                              TimelineTileWidget(
                                isFirst: false,
                                isLast: false,
                                isPast: false,
                                text: 'Processing your delivery',
                              ),
                              TimelineTileWidget(
                                isFirst: false,
                                isLast: true,
                                isPast: false,
                                text:
                                    'Delivery expected today : \n ${DateFormat('dd/MM/yyyy').format(snap?['placed_date'].toDate().add(Duration(days: 7)))}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                            onPressed: () {},
                            child: Text(
                              "Change DeliveryDate",
                              style: GoogleFonts.abhayaLibre(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.navigate_next,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
