import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatefulWidget {

  final List shoppingBag;
  final int total;
  CheckoutPage({
    @required this.shoppingBag,
    @required this.total
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  int total;
  List shoppingBag = List();

  @override
  void initState() {
    total = widget.total;
    shoppingBag = widget.shoppingBag;
    super.initState();
  }

  fetchImage(itemID) async{
    var ref = Firestore.instance.collection("items");
    var doc = await ref.document(itemID).get();
    return doc["imgURL"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: GoogleFonts.raleway(
            fontSize: 18,
            color: Colors.white
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 18
          ),
          child: ListView.builder(
            itemCount: shoppingBag.length,
            itemBuilder: (BuildContext context, int index){
              return Row(
                children: <Widget>[
                  Icon(
                    Icons.remove_circle_outline
                  ),
                  CircleAvatar(
                    radius: 18,
                    child: Image.network(
                      fetchImage(shoppingBag[index])
                    ),
                  ),
                  Row(
                    children: <Widget>[

                    ],
                  ),
                  Text(
                    "\u20B9 " + total.toString()
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}