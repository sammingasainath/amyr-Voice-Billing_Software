import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  BillingPageState createState() => BillingPageState();
}

class BillingPageState extends State<BillingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String selectedUnit = 'units';
  List<String> quantityUnits = [
    'units',
    'piece',
    'grams',
    'kilograms',
    'litres',
    'ml'
  ];

  List<String> testProductNames = [
    'Apple',
    'Banana',
    'Orange',
    'Mango',
    'Grapes',
    'Strawberry'
  ];

  List<Item> items = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildForm(),
            const SizedBox(height: 20),
            _buildItemList(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _checkout();
              },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SimpleAutoCompleteTextField(
            key: GlobalKey(),
            controller: nameController,
            suggestions: testProductNames,
            textChanged: (text) {},
            clearOnSubmit: false,
            textSubmitted: (text) {
              nameController.text = text;
            },
            decoration: const InputDecoration(labelText: 'Product Name'),
          ),
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
                items:
                    quantityUnits.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _addItem();
            },
            child: const Text('Add Item'),
          ),
        ],
      ),
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

  void _addItem() {
    if (nameController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      final newItem = Item(
        name: nameController.text,
        quantityUnit: selectedUnit,
        quantity: int.parse(quantityController.text),
        price: double.parse(priceController.text),
      );

      setState(() {
        items.add(newItem);
      });

      // Clear the text fields after adding an item
      nameController.clear();
      quantityController.clear();
      priceController.clear();
    }
  }

  void _checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(items: items),
      ),
    );
  }
}

class Item {
  final String name;
  final String quantityUnit;
  final int quantity;
  final double price;

  Item({
    required this.name,
    required this.quantityUnit,
    required this.quantity,
    required this.price,
  });
}

class CheckoutPage extends StatelessWidget {
  final List<Item> items;

  const CheckoutPage({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    for (var item in items) {
      totalPrice += item.price;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Items:'),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Name: ${items[index].name}'),
                    subtitle: Text(
                      'Quantity: ${items[index].quantity} ${items[index].quantityUnit} | Price: \$${items[index].price.toStringAsFixed(2)}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
