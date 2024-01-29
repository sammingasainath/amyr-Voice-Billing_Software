import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trial_voice/bill_generation.dart' as bill;
import 'package:trial_voice/payment_qr_code.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
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

    var url =
        'https://script.google.com/macros/s/AKfycbwqGKj67u9Ir6JRCPWQ5P3BZceDqLmzNIG4SP1n4Xhq0hIClTVQndB5C78aLKNTIrsPLw/exec?billID=$BillID&userID=$userUid';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save billing details
    prefs.setString('customerName', customerNameController.text);
    prefs.setString('customerNumber', customerNumberController.text);
    prefs.setString('selectedPaymentMode', selectedPaymentMode);
    prefs.setStringList('items',
        widget.items.map((item) => jsonEncode(item.toJson())).toList());
    prefs.setDouble('totalAmount', calculateTotalAmount());

    // Clear the items list

    //clear the shared preferences

    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    prefs1.remove('items');
    prefs1.setStringList('items',
        widget.items.map((item) => jsonEncode(item.toJson())).toList());

    // Send the bill to the customer via WhatsApp (you may need to implement this)
    // sendBillToWhatsApp(billData);

    // Navigate back to the previous screen
    WhatsappShare.share(
      text: 'Thank you for shopping with us. Here is your bill.',
      phone: customerNumberController.text,
      linkUrl: url, //country code + phone number
    );
    Navigator.pop(context);
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    for (Item item in widget.items) {
      totalAmount += item.price * item.quantity;
    }
    return totalAmount;
  }

  void showModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return MyQRCodeScreen(
          amount: calculateTotalAmount().toStringAsFixed(2),
        );
      },
    );
  }

  Widget _buildItemList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Items:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (widget.items.isEmpty)
            const Text('No items added yet.')
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
                            child: const Icon(Icons.add),
                          ),
                          const SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () {
                              if (item.quantity > 0) {
                                setState(() {
                                  item.quantity--;
                                });
                              }
                            },
                            child: const Icon(Icons.remove),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        widget.items.remove(item);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.mic),
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 26, 112, 211),
        title: const Text('Billing Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: customerNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Customer Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModal(context);
                  },
                  icon: const Icon(Icons.qr_code),
                ),
                const SizedBox(height: 5),
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
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    saveBillToFirestore();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save Bill',
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.save),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: _buildItemList(),
          ),
          Container(
            color: Color.fromARGB(
                255, 45, 94, 192), // Background color for total amount section
            padding: const EdgeInsets.all(25),
            child: Text(
              'Total Amount: ₹${calculateTotalAmount().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
