// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_threads/core/utilities.dart';

class AddAddressSingle extends StatefulWidget {
  const AddAddressSingle({
    super.key,
  });

  @override
  State<AddAddressSingle> createState() => _AddAddressSingleState();
}

class _AddAddressSingleState extends State<AddAddressSingle> {
  String? address;

  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController house = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController pincode = TextEditingController();

  Future addAddress() async {
    try {
      await FirebaseFirestore.instance.collection('address').add({
        'address':
            "${name.text}+${contact.text}+${house.text}(H)+${street.text}+${city.text}+${district.text}+${pincode.text}",
        'userId': FirebaseAuth.instance.currentUser!.email,
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    log(args.toString());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('address')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    log(snapshot.error.toString());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final snap = snapshot.data!.docs[index];
                      return RadioListTile(
                        value: snap['address'],
                        title: Text(
                          snap['address'].split("+").join("\n"),
                          style: GoogleFonts.abhayaLibre(),
                        ),
                        groupValue: address,
                        onChanged: (value) {
                          setState(() {
                            address = value;
                            log(address.toString());
                          });
                        },
                      );
                    },
                  );
                }),
            minheight,
            ExpansionTile(
              childrenPadding: EdgeInsets.all(10.0),
              title: Text(
                "Add Address",
                style: GoogleFonts.abhayaLibre(color: Colors.blueGrey),
              ),
              trailing: Icon(Icons.arrow_drop_down),
              backgroundColor: Colors.blue[50],
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: name,
                    style: GoogleFonts.abhayaLibre(),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      focusedBorder: OutlineInputBorder(),
                      labelStyle: GoogleFonts.abhayaLibre(
                          color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: contact,
                    maxLength: 10,
                    style: GoogleFonts.abhayaLibre(),
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      focusedBorder: OutlineInputBorder(),
                      labelStyle: GoogleFonts.abhayaLibre(
                          color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: house,
                    style: GoogleFonts.abhayaLibre(),
                    decoration: InputDecoration(
                      labelText: 'House Name/ House Number',
                      focusedBorder: OutlineInputBorder(),
                      labelStyle: GoogleFonts.abhayaLibre(
                          color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: street,
                    style: GoogleFonts.abhayaLibre(),
                    decoration: InputDecoration(
                      labelText: 'Street Name',
                      focusedBorder: OutlineInputBorder(),
                      labelStyle: GoogleFonts.abhayaLibre(
                          color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: city,
                    style: GoogleFonts.abhayaLibre(),
                    decoration: InputDecoration(
                      labelText: 'City',
                      focusedBorder: OutlineInputBorder(),
                      labelStyle: GoogleFonts.abhayaLibre(
                          color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: district,
                    style: GoogleFonts.abhayaLibre(),
                    decoration: InputDecoration(
                      labelText: 'District',
                      focusedBorder: OutlineInputBorder(),
                      labelStyle: GoogleFonts.abhayaLibre(
                          color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: pincode,
                    style: GoogleFonts.abhayaLibre(),
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Pin code',
                      focusedBorder: OutlineInputBorder(),
                      labelStyle: GoogleFonts.abhayaLibre(
                          color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (name.text.isNotEmpty &&
                          contact.text.isNotEmpty &&
                          house.text.isNotEmpty &&
                          street.text.isNotEmpty &&
                          city.text.isNotEmpty &&
                          district.text.isNotEmpty &&
                          pincode.text.isNotEmpty) {
                        setState(() {
                          addAddress();
                        });
                        name.clear();
                        contact.clear();
                        house.clear();
                        street.clear();
                        city.clear();
                        district.clear();
                        pincode.clear();
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Text("fields can't be empty"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Go back"))
                            ],
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(200, 50)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueGrey)),
                    child: Text(
                      "Save Address",
                      style: GoogleFonts.abhayaLibre(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            minheight,
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'singlecheckout', arguments: {
                    'address': address,
                    'image': args['image'],
                    'product_id': args['product_id'],
                    'product_name': args['product_name'],
                    'description': args['description'],
                    'details': args['details'],
                    'totalPrice': args['totalPrice'],
                    'size': args['size'],
                    'userId': FirebaseAuth.instance.currentUser!.email,
                  });
                },
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(200, 50)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blueGrey)),
                child: Text(
                  "Done",
                  style: GoogleFonts.abhayaLibre(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
