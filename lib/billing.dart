import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trial_voice/add_product.dart';

class Item {
  final String name;
  final String quantityUnit;
  final int quantity;
  final double price;
  final String barcode;

  Item({
    required this.name,
    required this.quantityUnit,
    required this.quantity,
    required this.price,
    required this.barcode,
  });
}

class BillingPage extends StatefulWidget {
  @override
  BillingPageState createState() => BillingPageState(productName: name1);

  const BillingPage({
    Key? key,
    required this.name1,
  }) : super(key: key);

  final name1;
}

class BillingPageState extends State<BillingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  BillingPageState({required productName}) {
    if (productName != null) {
      nameController.text = productName.toString();
      dosomething();
    }

    // nameController.text = productName.toString();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Use the initial value passed and set it in the controller
  //   nameController.text = widget.name1.toString();
  // }

  String selectedUnit = 'units';
  List<String> quantityUnits = [
    'units',
    'piece',
    'grams',
    'kilograms',
    'litres',
    'ml'
  ];

  List<Item> items = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildForm(),
          const SizedBox(height: 20),
          _buildItemList(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder<List<String>>(
          future: _getProductNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No products found.');
            } else {
              return SimpleAutoCompleteTextField(
                key: GlobalKey(),
                controller: nameController,
                suggestions: snapshot.data!,
                textChanged: (text) {
                  nameController.text = text;
                },
                clearOnSubmit: false,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Quantity Unit: '),
            DropdownButton<String>(
              value: selectedUnit,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue!;
                });
              },
              items: quantityUnits.map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: barcodeController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Barcode',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _addItem();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // background color
            onPrimary: Colors.white, // text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Add Item',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemList() {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(items[index].name),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                items.removeAt(index);
              });
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              title: Text('Name: ${items[index].name}'),
              subtitle: Text(
                'Quantity: ${items[index].quantity} ${items[index].quantityUnit} | Price: \$${items[index].price.toStringAsFixed(2)}',
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<String>> _getProductNames() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection(
              'Products') // Assuming 'Products' is the subcollection name
          .get();

      List<String> productNames = querySnapshot.docs
          .map((document) => document['productName'].toString())
          .toList();

      return productNames;
    } catch (e) {
      print('Error fetching product names: $e');
      return [];
    }
  }

  void dosomething() {
    setState(() {
      print('Inside Billing Screen ${ProductName.toString()}');
      nameController.text = ProductName.toString();
    });
  }

  void _addItem() {
    if (nameController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      final newItem = Item(
        name: nameController.text,
        quantityUnit: selectedUnit,
        quantity: int.parse(quantityController.text),
        price: double.parse(priceController.text),
        barcode: barcodeController.text,
      );

      setState(() {
        items.add(newItem);
      });

      // Clear the text fields after adding an item
      nameController.clear();
      quantityController.clear();
      priceController.clear();
      barcodeController.clear();
    }
  }
}



