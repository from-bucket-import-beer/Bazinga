import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Inventory extends StatefulWidget{
  final String name, quantity, img, pageTitle, price, shopID, itemID;
  Inventory({this.name, this.quantity, this.img, this.pageTitle, this.price, this.shopID, this.itemID});
  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  
  final key = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  File postImage;

  Widget title() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 150.0),
      child: Text(
        'Add Item',
        style: TextStyle(
          fontSize: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget item_picture() {
    return Padding(
      padding: EdgeInsets.only(top: 220.0, left: 145),
      child: Stack(
        children: <Widget>[
          Container(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: () async{
                var tempImgFile = await ImagePicker.pickImage(source: ImageSource.gallery);
                setState(() {
                  postImage = tempImgFile;
                });
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF0E3311).withOpacity(0.5),
                child: Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  Widget add_Item() {
    return Container(
      width: 350,
      padding: EdgeInsets.only(top: 370.0, left: 70.0),
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: 'Item Name',
          labelStyle: TextStyle(color: Colors.white, fontSize: 16.0),
          hintText: 'Choclates,etc.',
        ),
      ),
    );
  }

  Widget add_Quantity() {
    return Container(
      width: 350,
      padding: EdgeInsets.only(top: 450.0, left: 70.0),
      child: TextFormField(
        controller: quantityController,
        decoration: InputDecoration(
          
          labelText: 'Item Quantity',
          labelStyle: TextStyle(color: Colors.white, fontSize: 16.0),
          hintText: '1,2,3...',
        ),
      ),
    );
  }
  Widget add_Price() {
    return Container(
      width: 350,
      padding: EdgeInsets.only(top: 530.0, left: 70.0),
      child: TextFormField(
        controller: priceController,
        decoration: InputDecoration(
          labelText: 'Item Price',
          labelStyle: TextStyle(color: Colors.white, fontSize: 16.0),
          hintText: '200,1000...',
        ),
      ),
    );
  }

  @override
  void initState(){ 
    nameController.text = widget.name;
    quantityController.text = widget.quantity;
    priceController.text = widget.price;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
     body: SingleChildScrollView(
        child: Container(
      child: Stack(
        children: <Widget>[
          Image.asset(
            'assets/images/download.jpg',
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
          ),
          title(),
          item_picture(),
          add_Item(),
          add_Quantity(),
          add_Price(),
        ],
      ),
    )),
     floatingActionButton: FloatingActionButton(
       onPressed: () async{
          var collectionRef = Firestore.instance.collection("items");
          if(widget.itemID != null){
            await collectionRef.document(widget.itemID).delete();
          }
          Map<String, dynamic> details = {
            "name":nameController.text,
              "quantity": quantityController.text,
              "price": priceController.text,
              "imgURL": widget.img,
              "shopID": widget.shopID
          };
          if(postImage != null){
            if(widget.img.length == 0){
              var storageRef = FirebaseStorage.instance.ref();
              var locRef = storageRef.child("items");
              StorageUploadTask uploadTask = locRef.child(nameController.text + " - " + widget.shopID).putFile(postImage);
              StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
              var imgURL = await taskSnapshot.ref.getDownloadURL();
              details["imgURL"] = imgURL;
            }
            else{
              var storageRef = FirebaseStorage.instance.ref();
              var locRef = storageRef.child("items");
              await locRef.child(widget.name + " - " + widget.shopID).delete();
              StorageUploadTask uploadTask = locRef.child(nameController.text).putFile(postImage);
              StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
              var imgURL = await taskSnapshot.ref.getDownloadURL();
              details["imgURL"] = imgURL;
            }
          }
        await collectionRef.add(details);
        Navigator.pop(context);
      },
      child: Icon(Icons.done),
     ),
    );
  }

    
  }
