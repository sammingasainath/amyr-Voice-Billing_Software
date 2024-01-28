import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductListViewScreen1 extends StatefulWidget {
  const ProductListViewScreen1({super.key});

  @override
  _ProductListViewScreen1State createState() => _ProductListViewScreen1State();
}

class _ProductListViewScreen1State extends State<ProductListViewScreen1> {
  late Future<List<DocumentSnapshot>> _productsFuture;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = _getProducts();
  }

  Future<List<DocumentSnapshot>> _getProducts() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference productsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('Products');

    QuerySnapshot querySnapshot = await productsCollection.get();
    return querySnapshot.docs;
  }

  List<DocumentSnapshot> _filterProducts(
      List<DocumentSnapshot> products, String query) {
    return products
        .where((product) =>
            product['productName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            product['barcode']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _productsFuture = _getProducts(); // Reset the future
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found.'));
                } else {
                  var filteredProducts =
                      _filterProducts(snapshot.data!, searchController.text);

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var productData = filteredProducts[index].data() as Map;
                      return ListTile(
                        title: Text(productData['productName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barcode: ${productData['barcode']}'),
                            Text('Price: ₹${productData['sp']}'),
                            Text('Stock: ₹${productData['quantity']}'),
                            Text('Cost: ₹${productData['cp']}'),

                            // Add more details as needed
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
