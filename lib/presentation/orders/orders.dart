// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trippy_threads/presentation/orders/order_detail.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                log(snapshot.error.toString());
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              return ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final snap = snapshot.data!.docs[index];
                  DateTime placedDate =
                      DateFormat('dd/MM/yyyy').parse(snap['placed_date']);
                  final expectedDeliveryDate = DateFormat('dd/MM/yyyy')
                      .format(placedDate.add(Duration(days: 7)));

                  return ListTile(
                    style: ListTileStyle.list,
                    leading: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(snap['image'][0])),
                          border: Border.all(color: Colors.black)),
                    ),
                    title: Text(
                      "Expected delivery on $expectedDeliveryDate",
                      style: GoogleFonts.acme(color: Colors.greenAccent),
                    ),
                    subtitle: Text(
                      snap['product_name'],
                      style: GoogleFonts.acme(color: Colors.black),
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetail(orderId: snap.id),
                              ));
                        },
                        icon: Icon(
                          Icons.navigate_next,
                          color: Colors.black,
                        )),
                  );
                },
              );
            }),
      ),
    );
  }
}
