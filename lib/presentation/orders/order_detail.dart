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
        backgroundColor: bgcolor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: buttonbg),
          backgroundColor: bgcolor,
          title: Text(
            "Order Details",
            style: GoogleFonts.acme(color: fontcolor),
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

            final expectedDeliveryDate = snap['expected'];

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
                                  color: fontcolor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              minheight,
                              Text(
                                snap['description'],
                                style: GoogleFonts.acme(color: fontcolor),
                              ),
                              minheight,
                              Text(
                                "₹ ${snap['totalPrice']} /-",
                                style: GoogleFonts.acme(
                                  color: fontcolor,
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
                    snap['track'] != "cancelled"
                        ? Row(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(buttonbg),
                                ),
                                onPressed: () async {
                                  // Parse the current expected date from the string format (dd/MM/yyyy)
                                  DateTime initialDate =
                                      DateFormat('dd/MM/yyyy')
                                          .parse(snap['expected']);

                                  // Show DatePicker with the initial date and limit the selectable date range
                                  DateTime? newDate = await showDatePicker(
                                    context: context,
                                    firstDate: initialDate,
                                    lastDate:
                                        initialDate.add(Duration(days: 7)),
                                    initialDate: initialDate,
                                  );

                                  // If a new date is selected, format it to dd/MM/yyyy and update Firestore
                                  if (newDate != null) {
                                    String formattedNewDate =
                                        DateFormat('dd/MM/yyyy')
                                            .format(newDate);

                                    // Update the Firestore document with the new delivery date
                                    await FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc(widget.orderId)
                                        .update({
                                      'expected': formattedNewDate,
                                    });

                                    // Show a SnackBar confirming the update
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Delivery date updated to $formattedNewDate")),
                                    );

                                    // Refresh the UI
                                    setState(() {});
                                  }
                                },
                                child: Text(
                                  "Change Delivery Date",
                                  style: GoogleFonts.acme(
                                      color: buttonfont, fontSize: 16),
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(buttonbg),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text(
                                          "are you really wanna cancel your order ?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("No")),
                                        TextButton(
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('orders')
                                                  .doc(widget.orderId)
                                                  .update(
                                                      {'track': "cancelled"});
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            child: Text("Yes")),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                  "Cancel your Order",
                                  style: GoogleFonts.acme(
                                      color: buttonfont, fontSize: 16),
                                ),
                              ),
                              Spacer(),
                            ],
                          )
                        : SizedBox(
                            height: 10,
                          )
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
