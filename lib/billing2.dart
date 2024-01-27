import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:trial_voice/api/api_key.dart';
import 'form.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'products_list.dart';
// import 'billing.dart';
import 'fetching_name_and_qty.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trial_voice/add_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

var ProductName = null;
var CP = null;
var MRP = null;
var SP = null;
var Stock = null;
var result = false;
String inCompleteTask = '';
BuildContext? currentContext;
var SearchText = '';

class SpeechSampleApp1 extends StatefulWidget {
  const SpeechSampleApp1({
    Key? key,
  }) : super(key: key);

  @override
  State<SpeechSampleApp1> createState() => _SpeechSampleApp1State();
}

/// An example that demonstrates the basic functionality of the
/// SpeechToText plugin for using the speech recognition capability
/// of the underlying platform.
class _SpeechSampleApp1State extends State<SpeechSampleApp1> {
  bool _hasSpeech = false;
  bool _logEvents = false;
  bool _onDevice = false;
  final TextEditingController _pauseForController =
      TextEditingController(text: '3');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String prompt = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  var flutterTts = FlutterTts();

  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    initSpeechState();
    BillingPageState().productNameFocus.requestFocus();
  }

  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  ///
  ///

  speak(String text) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(0.8);

    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    // var voice = flutterTts.getVoices;
    // print(voice.toString());
    // await flutterTts.setVoice({"name": "Zira", "locale": "en-US"});
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
      );
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        _localeNames = await speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCC200),
          title: const Text(
            'AmyR AI Assist - Billing',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: BillingPage()),
            // Expanded(
            //   child: Container(
            //     padding: EdgeInsets.all(30),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: RecognitionResultsWidget(
            //         lastWords: lastWords, level: level),
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InitSpeechWidget(_hasSpeech, initSpeechState),
                    RecognitionResultsWidget(lastWords: lastWords),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListViewScreen(),
                          ),
                        );
                      },
                      child: const Text('Product List'),
                    ),
                  ],
                ),
                SpeechControlWidget(
                  _hasSpeech,
                  speech.isListening,
                  speech.isListening ? stopListening : startListening,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    // Note that `listenFor` is the maximum, not the minimum, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: listenFor ?? 30),
      pauseFor: Duration(seconds: pauseFor ?? 3),
      partialResults: true,
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
      onDevice: _onDevice,
    );
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';

      // if (result.recognizedWords == 'yes' ||
      //     result.recognizedWords == 'Yes' ||
      //     result.recognizedWords == 'YES') {
      //   AddProductModalState().scanBarcode();
      // } else if (result.recognizedWords == 'no' ||
      //     result.recognizedWords == 'No' ||
      //     result.recognizedWords == 'NO') {}

      // print(prompt);
      if (result.finalResult == true) {
        prompt = result.recognizedWords;

        afterResponse(prompt);
      }
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  Future<Map<String, dynamic>> sendChatCompletionRequest(String prompt) async {
    // Replace 'YOUR_AUTH_TOKEN' with your actual OpenAI API key
    var result = await sendChatCompletionRequest1(prompt);

    print('Result is $result');

    if (result['productName'] == null) {
      await speak('Please Fill $inCompleteTask');
      Timer(Duration(seconds: 4), () {
        startListening();
      });
    } else {
      await speak('Scan Here ?');
      setState(() {
        saveResultToSharedPreferences(result['productName']);
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SpeechSampleApp1(),
          ),
        );
        BillingPageState().productNameFocus.requestFocus();
      });
    }

    //From Here I have to Change ;;;;

    return result;
  }

  Future<void> saveResultToSharedPreferences(String productName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('productName', productName);

    print('Turr');

    print(prefs.getString('productName'));

    // Notify the BillingPage widget about the update

    BillingPageState().getProductNameFromSharedPreferences();
  }

  void afterResponse(String prompt) async {
    // Do something after the response has been receivedprint(prompt);

    await sendChatCompletionRequest(prompt).then((value) async {
      // String toBeExtracted = '''$value''';

      // Map<String, dynamic> extractedInfo =
      // await extractInformationFromApiResponse(value);
      // print(extractedInfo);
      setState(() {
        // lastWords = value.toString();
      });
    });
  }

  void errorListener(SpeechRecognitionError error) {
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = status;
    });
  }

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    debugPrint(selectedVal);
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      debugPrint('$eventTime $eventDescription');
    }
  }

  void _switchLogging(bool? val) {
    setState(() {
      _logEvents = val ?? false;
    });
  }

  void _switchOnDevice(bool? val) {
    setState(() {
      _onDevice = val ?? false;
    });
  }
}

/// Displays the most recently recognized words and the sound level.
class RecognitionResultsWidget extends StatelessWidget {
  const RecognitionResultsWidget({
    Key? key,
    required this.lastWords,
  }) : super(key: key);

  final String lastWords;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 2,
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lastWords,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

// class HeaderWidget extends StatelessWidget {
//   const HeaderWidget({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text(
//         'Press Start ',
//         style: TextStyle(fontSize: 22.0),
//       ),
//     );
//   }
// }

/// Display the current error status from the speech
/// recognizer
class ErrorWidget extends StatelessWidget {
  const ErrorWidget({
    Key? key,
    required this.lastError,
  }) : super(key: key);

  final String lastError;

  void showModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AddProductModal(
            context1: context,
            barcode: 'barcode',
            productName: ProductName,
            mRP: MRP,
            cP: CP,
            sP: SP,
            quantity: Stock);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Text(''),
    );
  }
}

/// Controls to start and stop speech recognition
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
      height: 100,
      width: 100,
      child: FloatingActionButton(
          isExtended: true,
          onPressed: hasSpeech ? toggleListening : null,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color:
                    isListening ? const Color(0xFFFCC200) : Color(0xFFaa0505),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(50.0)),
          backgroundColor: isListening ? Color(0xFFaa0505) : Color(0xFFFCC200),
          child: Image.asset(
            'assets/logo.png',
            alignment: Alignment.center,
            color: isListening ? const Color(0xFFFCC200) : Color(0xFFaa0505),
            width: 200,
            height: 200.0,
          )),
    );
  }
}

class InitSpeechWidget extends StatelessWidget {
  const InitSpeechWidget(this.hasSpeech, this.initSpeechState, {Key? key})
      : super(key: key);

  final bool hasSpeech;

  final Future<void> Function() initSpeechState;

  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextButton(
          onPressed: hasSpeech ? null : initSpeechState,
          child: const Text(''),
        ),
      ],
    );
  }
}

/// Display the current status of the listener
class SpeechStatusWidget extends StatelessWidget {
  const SpeechStatusWidget({
    Key? key,
    required this.speech,
  }) : super(key: key);

  final SpeechToText speech;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: speech.isListening
            ? const Text(
                "I'm listening...",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text(
                'Not listening',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class SpokenTextWidget extends StatelessWidget {
  final String lastWords;

  const SpokenTextWidget({Key? key, required this.lastWords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        lastWords,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ProductListViewScreen extends StatefulWidget {
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
        title: Text('Product List'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found.'));
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

class BillingPage extends StatefulWidget {
  @override
  BillingPageState createState() => BillingPageState();

  const BillingPage({Key? key}) : super(key: key);
}

class BillingPageState extends State<BillingPage> {
  final FocusNode productNameFocus = FocusNode();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getProductNameFromSharedPreferences();

    // Use the initial value passed and set it in the controller
  }

  Future<void> fetchDataAndSetState() async {
    // Simulating an asynchronous operation, e.g., fetching data
    await Future.delayed(Duration(seconds: 2));

    // Update the state using setState
    setState(() {});
  }

  Future<void> getProductNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var productName1 = prefs.getString('productName');

    print('Furr');

    print(productName1?.toString());

    if (productName1 != null && productName1.isNotEmpty) {
      print('If Loop Is Excecuting');

      nameController.text = productName1.toString();
    }
  }

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
                focusNode: productNameFocus,
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