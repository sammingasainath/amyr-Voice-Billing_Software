import 'dart:async';
import 'api/api_key.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

Future<Map<String, dynamic>> sendChatCompletionRequest1(String prompt) async {
  // Replace 'YOUR_AUTH_TOKEN' with your actual OpenAI API key

  var inCompleteTask = '';
  var ProductName = null;
  var Quantity = null;
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
          "content": " Extract ProductName , Quantity and return the object,if there is no ProductName or no Quantity, set the respective value as null , the json object should be like object like {productName:,Quantity, in which the Product Name is a String, and Quantity are Numbers, so please see that only numbers are there in this field, for this message :$prompt"
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
      print(response.body);

      inCompleteTask = '';

      Map<String, dynamic> apiResponse = json.decode(response.body);
      // String id = json.decode(response.body)['id'];
      // print(id);

      String message = apiResponse['choices'][0]['message']['content'];
      Map<String, dynamic> productjson = json.decode(message);

      if ((productjson['productName'] != null)) {
        ProductName = productjson['productName'];

        print(ProductName);
      }
      // } else if (ProductName != null) {
      //   ProductName = ProductName;
      // } else {
      //   inCompleteTask += 'Product Name,';
      // }

      if (productjson['Quantity'] != null) {
        Quantity = productjson['Quantity'];
        print(Quantity);
      }
      // } else if (Quantity != null) {
      //  Quantity = Quantity;
      // } else {
      //   inCompleteTask += 'Quantity';
      // }

      // String role = message['role'];
      // print(role);

      print(message);
      // setState(() {
      //   lastWords = message.toString();
      // });

      return (productjson);
    } else {
      print('Error: ${response.statusCode}');
      // print('Response Body: ${response.body}');
      // Handle errors here if needed
      return {'error': 'Failed to get response'};
    }
  } catch (error) {
    print('Error: $error');
    // Handle errors here if needed
    return {'error': 'Failed to make the request'};
  }
}
