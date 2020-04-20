import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'successful.dart';

class OrderDetails extends StatefulWidget {

  final List<Widget> items;
  final String orderID, orderedBy, orderedAt;
  final bool isActive;
  OrderDetails({
    @required this.items,
    @required this.orderID,
    @required this.orderedBy,
    @required this.orderedAt,
    @required this.isActive
  });

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {

  var result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: GoogleFonts.raleway(
            fontSize: 18
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: widget.items,
          ),
        ),
      ),
      floatingActionButton: widget.isActive ? FloatingActionButton.extended(
        onPressed: () async{
          var ref = Firestore.instance.collection("orders");
          result = await BarcodeScanner.scan();
          var res = json.decode(result.rawContent.toString());
          if(res["orderedBy"] == widget.orderedBy && res["orderID"] == widget.orderID){
            var doc = await ref.document(widget.orderID).get();
            var updatedDetails = doc.data;
            updatedDetails["isActive"] = false;
            await ref.document(widget.orderID).setData(updatedDetails);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SuccessfulScreen()
              )
            );
          }
        },
        label: Text(
          "Scan QR Code",
          style: GoogleFonts.raleway(
            fontSize: 16
          ),
        ),
        icon: Icon(Icons.photo_camera),
      ) : Container(),
    );
  }
}