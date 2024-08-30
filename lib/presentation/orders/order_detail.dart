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
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.black,
          title: Text(
            "Order Details",
            style: GoogleFonts.acme(color: Colors.black),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.orderId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              log(snapshot.error.toString());
              return Center(child: Text("Something went wrong"));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("No order data available"));
            }

            final snap = snapshot.data!.data() as Map<String, dynamic>?;
            if (snap == null) {
              return Center(child: Text("No order data available"));
            }

            DateTime placedDate =
                DateFormat('dd/MM/yyyy').parse(snap['placed_date']);
            final expectedDeliveryDate = DateFormat('dd/MM/yyyy')
                .format(placedDate.add(Duration(days: 7)));

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    minheight,
                    Text(
                      "Order ID : ${widget.orderId}",
                      style: GoogleFonts.acme(color: Colors.greenAccent),
                    ),
                    minheight,
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snap['product_name'],
                                style: GoogleFonts.acme(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              minheight,
                              Text(
                                snap['description'],
                                style: GoogleFonts.acme(color: Colors.black),
                              ),
                              minheight,
                              Text(
                                "₹ ${snap['totalPrice']} /-",
                                style: GoogleFonts.acme(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(snap['image'][0]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              text: 'Order placed : \n${snap['placed_date']}',
                            ),
                            TimelineTileWidget(
                              isFirst: false,
                              isLast: false,
                              isPast: snap['track'] == "assigned" ||
                                  snap['track'] == "recieved" ||
                                  snap['track'] == "out for delivery" ||
                                  snap['track'] == "nearest hub" ||
                                  snap['track'] == "delivered",
                              text: 'Acknowledged',
                            ),
                            TimelineTileWidget(
                              isFirst: false,
                              isLast: false,
                              isPast: snap['track'] == "recieved" ||
                                  snap['track'] == "out for delivery" ||
                                  snap['track'] == "nearest hub" ||
                                  snap['track'] == "delivered",
                              text: 'Received',
                            ),
                            TimelineTileWidget(
                              isFirst: false,
                              isLast: false,
                              isPast: snap['track'] == "out for delivery" ||
                                  snap['track'] == "nearest hub" ||
                                  snap['track'] == "delivered",
                              text: 'Out for delivery',
                            ),
                            TimelineTileWidget(
                              isFirst: false,
                              isLast: false,
                              isPast: snap['track'] == "nearest hub" ||
                                  snap['track'] == "delivered",
                              text:
                                  'Reached your nearest hub \n Delivery expected today :  $expectedDeliveryDate',
                            ),
                            TimelineTileWidget(
                              isFirst: false,
                              isLast: true,
                              isPast: snap['track'] == "delivered" ||
                                  snap['track'] == "return" ||
                                  snap['track'] == "cancelled",
                              text: snap['track'] == "delivered"
                                  ? 'Delivered'
                                  : snap['track'] == "return"
                                      ? 'Returned'
                                      : snap['track'] == "cancelled"
                                          ? 'Cancelled'
                                          : 'Delivered',
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
                                MaterialStateProperty.all(Colors.black),
                          ),
                          onPressed: () {
                            showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 7)),
                            );
                          },
                          child: Text(
                            "Change Delivery Date ",
                            style: GoogleFonts.acme(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
