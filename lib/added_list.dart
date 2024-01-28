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
        backgroundColor: Colors.blueAccent,
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
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.inventory_2_outlined,
                        color: Colors.blueAccent),
                    title: Text(
                      productData['productName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Barcode: ${productData['barcode']}'),
                    // Add more details as needed
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class RecognitionResultsWidget extends StatelessWidget {
  const RecognitionResultsWidget({
    Key? key,
    required this.lastWords,
    required this.level,
  }) : super(key: key);

  final String lastWords;
  final double level;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Container(
                child: Center(
                  child: Text(
                    lastWords,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned.fill(
                bottom: 300,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurRadius: .26,
                            spreadRadius: level * 1.5,
                            color: Color.fromARGB(255, 70, 172, 250)
                                .withOpacity(.05))
                      ],
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.star,
                        color: Color.fromARGB(255, 6, 92, 221),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SpeechControlWidget extends StatelessWidget {
  const SpeechControlWidget(
      this.hasSpeech, this.isListening, this.toggleListening,
      {Key? key})
      : super(key: key);

  final bool hasSpeech;
  final bool isListening;
  final void Function() toggleListening;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // bottom: 16.0,
      // right: 10.0,
      height: 80,
      width: 80,
      child: FloatingActionButton(
          isExtended: true,
          onPressed: hasSpeech ? toggleListening : null,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isListening
                    ? Color.fromARGB(255, 33, 108, 199)
                    : Color.fromARGB(255, 0, 0, 0),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(50.0)),
          backgroundColor: isListening
              ? Color.fromARGB(255, 48, 130, 224)
              : Color.fromARGB(255, 0, 0, 0),
          tooltip: isListening ? 'Listening...' : 'Not listening',
          child: Image.asset(
            'assets/logo.png',
            alignment: Alignment.center,
            color: isListening
                ? Color.fromARGB(255, 0, 0, 0)
                : Color.fromARGB(255, 5, 83, 135),
            width: 100,
            height: 100.0,
          )),
    );
  }
}
