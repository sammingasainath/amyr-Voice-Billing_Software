import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:trial_voice/added_list.dart';
import 'package:trial_voice/api/api_key.dart';
import 'form.dart';
import 'package:flutter_tts/flutter_tts.dart';

var ProductName;
var CP;
var MRP;
var SP;
var Stock;
var result = false;
String inCompleteTask = '';
BuildContext? currentContext;

class SpeechSampleApp extends StatefulWidget {
  const SpeechSampleApp({Key? key}) : super(key: key);

  @override
  State<SpeechSampleApp> createState() => _SpeechSampleAppState();
}

/// An example that demonstrates the basic functionality of the
/// SpeechToText plugin for using the speech recognition capability
/// of the underlying platform.
class _SpeechSampleAppState extends State<SpeechSampleApp> {
  void showModal(context) async {
    result = await showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AddProductModal(
            context1: context,
            barcode: 'Scan Barcode',
            productName: ProductName,
            mRP: MRP,
            cP: CP,
            sP: SP,
            quantity: Stock);
      },
    );

    if (result) {
      setState(() {
        ProductName = null;
        CP = null;
        MRP = null;
        SP = null;
        Stock = null;
        lastWords = '';
      });
    }
  }

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
        floatingActionButton: SpeechControlWidget(
          _hasSpeech,
          speech.isListening,
          speech.isListening ? stopListening : startListening,
        ),
        appBar: AppBar(
          leading: BackButton(
            onPressed: Navigator.of(context).pop,
          ),
          title: const Text(
            'AmyR AI Assist - Stock In',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: RecognitionResultsWidget(
                  lastWords: lastWords,
                  level: level,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SpeechStatusWidget(speech: speech),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListViewScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                      onPrimary: Colors.white,
                    ),
                    child: const Text(
                      'Product List',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InitSpeechWidget(_hasSpeech, initSpeechState),
                    ],
                  ),
                ],
              ),
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
    String authToken = api_key;
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    // Replace this with your JSON body
    String requestBody = '''
    {
      "messages": [
        {
          "role": "system",
          "content": "You are supposed to return a pure json object in the desired format according to the prompt, Do not return \\n and extra things in the output "
        },
        {
          "role": "user",
          "content": " Extract ProductName , MRP, SP, CP and Stock and return the object,if there is no ProductName or no MRP or no SP or no CP or no Stock , set the respective value as null , the json object should be like object like {productName:,MRP:,CP:,SP:,Stock}, in which the Product Name is a String, and MRP,CP,SP,Stock are Numbers, so please see that only numbers are there in this field, for this message :$prompt"
        }
      ],
      "model": "gpt-3.5-turbo",
      "max_tokens": 200
    }
  ''';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // print(response.body);

        inCompleteTask = '';

        Map<String, dynamic> apiResponse = json.decode(response.body);
        // String id = json.decode(response.body)['id'];
        // print(id);

        String message = apiResponse['choices'][0]['message']['content'];
        Map<String, dynamic> productjson = json.decode(message);

        if ((productjson['productName'] != null)) {
          ProductName = productjson['productName'];
        } else if (ProductName != null) {
          ProductName = ProductName;
        } else {
          inCompleteTask += 'Product Name,';
        }

        if (productjson['MRP'] != null) {
          MRP = productjson['MRP'];
        } else if (MRP != null) {
          MRP = MRP;
        } else {
          inCompleteTask += 'MRP,';
        }

        if (productjson['CP'] != null) {
          CP = productjson['CP'];
        } else if (CP != null) {
          CP = CP;
        } else {
          inCompleteTask += 'CP,';
        }

        if (productjson['SP'] != null) {
          SP = productjson['SP'];
        } else if (SP != null) {
          SP = SP;
        } else {
          inCompleteTask += 'SP,';
        }

        if (productjson['Stock'] != null) {
          Stock = productjson['Stock'];
        } else if (Stock != null) {
          Stock = Stock;
        } else {
          inCompleteTask += 'Stock,';
        }

        // String role = message['role'];
        // print(role);

        // setState(() {
        //   lastWords = message.toString();
        // });

        if (ProductName == null ||
            MRP == null ||
            CP == null ||
            SP == null ||
            Stock == null) {
          await speak('Please Fill $inCompleteTask');
          Timer(const Duration(seconds: 5), () {
            startListening();
          });
        } else {
          await speak('Scan Barcode ?');

          showModal(currentContext);
          
        }

        return (productjson);
      } else {
        // print('Response Body: ${response.body}');
        // Handle errors here if needed
        return {'error': 'Failed to get response'};
      }
    } catch (error) {
      // Handle errors here if needed
      return {'error': 'Failed to make the request'};
    }
  }

  void afterResponse(String prompt) async {
    // Do something after the response has been receivedprint(prompt);

    await sendChatCompletionRequest(prompt).then((value) async {
      // String toBeExtracted = '''$value''';

      // Map<String, dynamic> extractedInfo =
      // await extractInformationFromApiResponse(value);
      // print(extractedInfo);
      setState(() {
        lastWords = value.toString();
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
      child: const Text(''),
    );
  }
}

/// Controls to start and stop speech recognition

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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
