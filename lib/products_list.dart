import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductListViewScreen extends StatefulWidget {
  const ProductListViewScreen({super.key});

  @override
  _ProductListViewScreenState createState() => _ProductListViewScreenState();
}

class _ProductListViewScreenState extends State<ProductListViewScreen> {
  Future<List<DocumentSnapshot>> _getProducts() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference productsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('Products');

    QuerySnapshot querySnapshot = await productsCollection.get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            return ListView.builder(
              
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {

                var productData = snapshot.data![index].data() as Map;
                return ListTile(
                  title: Text(productData['productName']),
                  subtitle: Text('Barcode: ${productData['barcode']}'),
                  // Add more details as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
