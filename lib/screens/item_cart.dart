import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nima/nima_actor.dart';
import 'item_insert.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemDisplay extends StatefulWidget{

  final String email;
  ItemDisplay({this.email});
  
  @override
  ItemDisplayState createState() => ItemDisplayState();

}

class ItemDisplayState extends State<ItemDisplay>{

  var shopID;

  getItems() async{
    var ref = Firestore.instance;
    var shopRef = await ref.collection("shops").where("ownerEmail", isEqualTo: widget.email).getDocuments();
    shopID = shopRef.documents[0].documentID;
    var items = await ref.collection("items").where("shopID", isEqualTo: shopID).getDocuments();
    return items;
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: FutureBuilder(
        future: getItems(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data.documents.length != 0){
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index){
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: snapshot.data.documents[index]["imgURL"].length > 0 ? Image.network(
                        snapshot.data.documents[index]["imgURL"],
                        fit: BoxFit.contain,
                      ) : Text(
                        snapshot.data.documents[index]["name"].toString()[0].toUpperCase(),
                        style: GoogleFonts.varelaRound(
                          fontSize: 18,
                          color: Colors.white
                        ),
                      )
                    ),
                    title: Text(
                      snapshot.data.documents[index]["name"]
                    ),
                    subtitle: Text(
                      "Quantity: " + snapshot.data.documents[index]["quantity"]
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Inventory(
                            pageTitle: 'Edit Item Details',
                            name: snapshot.data.documents[index]["name"],
                            img: snapshot.data.documents[index]["imgURL"],
                            quantity: snapshot.data.documents[index]["quantity"],
                            price: snapshot.data.documents[index]["price"],
                            shopID: shopID,
                            itemID: snapshot.data.documents[index].documentID
                          )
                        )
                      ).then((onValue){
                        setState(() {});
                      });
                    }
                  );
                }
              );
            }
            else{
              return Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Center(
                        child: NimaActor(
                          "assets/flares/oops.nma",
                          fit: BoxFit.contain,
                          animation: "Idle",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Please add a few items first!",
                      style: GoogleFonts.raleway(
                        fontSize: 24
                      ),
                    )
                  ],
                ),
              );
            }
          }
          else{
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Inventory(
                pageTitle: 'Add Item',
                name: '',
                img: '',
                quantity: '',
                price: '',
                shopID: shopID,
                itemID: null
              )
            )
          ).then((onValue){
            setState((){});
          });
        },
        child: Icon(Icons.add),
      )
    );
  }
}