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
  String selectedCategory = 'All Categories'; // Initial value

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

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
      // You can apply additional filtering logic based on the selected category if needed.
      // For now, we'll use the selected category as a dummy value.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        backgroundColor: Colors.lightBlue,
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            items: <String>[
              'All Categories',
              'Category A',
              'Category B',
              'Category C'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              _onCategoryChanged(newValue ?? 'All Categories');
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Handle filter button press if needed
              // For now, we'll print the selected category
              print('Filter pressed for category: $selectedCategory');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.blue[50],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  setState(() {
                    _productsFuture = _getProducts(); // Reset the future
                  });
                },
              ),
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
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            productData['productName'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Barcode: ${productData['barcode']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Price: ₹${productData['sp']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Stock: ${productData['quantity']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                'Cost: ₹${productData['cp']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                              // Add more details as needed
                            ],
                          ),
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
