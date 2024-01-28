import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'barcode_for_product.dart';

class AddProductModal extends StatefulWidget {
  final barcode;
  final productName;
  final quantity;
  final mRP;
  final sP;
  final cP;
  final BuildContext context1;

  const AddProductModal({
    Key? key,
    required this.barcode,
    required this.productName,
    required this.quantity,
    required this.mRP,
    required this.sP,
    required this.cP,
    required this.context1,
  }) : super(key: key);

  @override
  AddProductModalState createState() => AddProductModalState();
}

class AddProductModalState extends State<AddProductModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController productNameController = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController spController = TextEditingController();
  TextEditingController cpController = TextEditingController();

  String selectedUnit = 'piece';
  String selectedSupplier = 'Default Supplier';
  String selectedCategory = 'Default Category';

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) {
      barcodeController.text = widget.barcode.toString();
    }

    if (widget.productName != null) {
      productNameController.text = widget.productName.toString();
    }
    if (widget.quantity != null) {
      quantityController.text = widget.quantity.toString();
    }

    if (widget.mRP != null) {
      mrpController.text = widget.mRP.toString();
    }
    if (widget.sP != null) {
      spController.text = widget.sP.toString();
    }
    if (widget.cP != null) {
      cpController.text = widget.cP.toString();
    }
  }

  Future<void> scanBarcode() async {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context1) {
        return MyHomePage(
          context2: widget.context1,
          barcode: 'barcode',
          productName: widget.productName,
          mRP: widget.mRP,
          cP: widget.cP,
          sP: widget.sP,
          quantity: widget.quantity,
        );
      },
    );

    barcodeController.text = widget.barcode;
  }

  Future<void> _saveProduct() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;
      CollectionReference productsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .collection('Products');

      await productsCollection.doc(widget.barcode.toString()).set({
        'productName': productNameController.text,
        'barcode': barcodeController.text,
        'quantity': quantityController.text,
        'mrp': mrpController.text,
        'sp': spController.text,
        'cp': cpController.text,
        'unit': selectedUnit,
        'supplierName': selectedSupplier,
        'category': selectedCategory,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product saved successfully!'),
        ),
      );
    } catch (e) {
      print('Error saving product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: productNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: barcodeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter barcode';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Barcode'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera),
                    onPressed: () {
                      scanBarcode();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: quantityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: mrpController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter MRP';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'MRP'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: spController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter SP';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'SP'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: cpController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CP';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CP'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value!;
                        });
                      },
                      items: ['piece', 'kilograms', 'grams', 'litres', 'ml']
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSupplier,
                      onChanged: (value) {
                        setState(() {
                          selectedSupplier = value!;
                        });
                      },
                      items: ['Default Supplier', 'Supplier 1', 'Supplier 2']
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      decoration:
                          const InputDecoration(labelText: 'Supplier Name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      items: ['Default Category', 'Category 1', 'Category 2']
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveProduct();
                  }
                  Navigator.pop(context, true);
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
