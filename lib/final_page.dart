import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trial_voice/bill_generation.dart' as bill;
import 'billing2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingScreen extends StatefulWidget {
  List<Item> items = [];

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerNumberController =
      TextEditingController();
  String selectedPaymentMode = 'Cash';
  String BillID = '';

  @override
  void initState() {
    super.initState();
    loadItemsFromSharedPreferences();
  }

  Future<void> loadItemsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemsJsonList = prefs.getStringList('items');

    if (itemsJsonList != null) {
      List<Item> loadedItems = itemsJsonList
          .map((jsonString) => Item.fromJson(jsonDecode(jsonString)))
          .toList();
      setState(() {
        widget.items.addAll(loadedItems);
      });
    }
  }

  void saveBillToFirestore() async {
    // Assuming you have a 'users' collection in Firestore
    String userUid = FirebaseAuth.instance.currentUser!.uid;

    // Create a new document in the 'Bills' subcollection
    CollectionReference billsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('Bills');

    // Deduct the quantities from Firebase Firestore
    for (Item item in widget.items) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('Products')
          .doc(item.barcode)
          .update({'quantity': FieldValue.increment(-item.quantity)});
    }

    var billData = {
      'customerName': customerNameController.text,
      'customerNumber': customerNumberController.text,
      'paymentMode': selectedPaymentMode,
      'items': widget.items.map((item) => item.toJson()).toList(),
      'totalAmount': calculateTotalAmount(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    DocumentReference billReference = await billsCollection.add(billData);

    // Print the document ID to the debug console
    print('Document ID: ${billReference.id}');

    BillID = '${billReference.id}';
    print(BillID);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save billing details
    prefs.setString('customerName', customerNameController.text);
    prefs.setString('customerNumber', customerNumberController.text);
    prefs.setString('selectedPaymentMode', selectedPaymentMode);
    prefs.setStringList('items',
        widget.items.map((item) => jsonEncode(item.toJson())).toList());
    prefs.setDouble('totalAmount', calculateTotalAmount());

    // Send the bill to the customer via WhatsApp (you may need to implement this)
    // sendBillToWhatsApp(billData);

    // Navigate back to the previous screen
    // Navigator.pop(context);
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    for (Item item in widget.items) {
      totalAmount += item.price * item.quantity;
    }
    return totalAmount;
  }

  Widget _buildItemList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Items:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        if (widget.items.isEmpty)
          Text('No items added yet.')
        else
          Column(
            children: widget.items.map((item) {
              double itemAmount = item.price * item.quantity;

              return ListTile(
                title: Text(item.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${item.quantity}'),
                    Text('Item Amount: ₹${itemAmount.toStringAsFixed(2)}'),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              item.quantity++;
                            });
                          },
                          child: Text('+'),
                        ),
                        SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            if (item.quantity > 0) {
                              setState(() {
                                item.quantity--;
                              });
                            }
                          },
                          child: Text('-'),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      widget.items.remove(item);
                    });
                  },
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 10),
        Text(
          'Total Amount: ₹${calculateTotalAmount().toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: customerNameController,
                decoration: InputDecoration(labelText: 'Customer Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: customerNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Customer Number'),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedPaymentMode,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMode = newValue!;
                  });
                },
                items: ['Cash', 'Card', 'UPI'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  saveBillToFirestore();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => bill.BillScreen1(),
                    ),
                  );
                },
                child: Text('Save Bill'),
              ),
              SizedBox(height: 20),
              _buildItemList(),
            ],
          ),
        ),
      ),
    );
  }
}
