import 'dart:async';
import 'dart:convert';

import 'package:butter/config/config.dart';
import 'package:http/http.dart' as http;

final url = '${Config.toasterHost}/graphql';

final Map<String, String> headers = {
  'Authorization': 'Bearer breadcat',
  'Content-type': 'application/json',
  'Accept': 'application/json',
};

class Toaster {
  static Future<Map<String, dynamic>> get(String body, {Map<String, dynamic> variables}) async {
    var requestBody = json.encode({'query': body });
    var response = await http.post(url, body: requestBody, headers: headers);
    var responseBody = json.decode(response.body);
    if (response.statusCode != 200 || responseBody['errors'] != null) {
      print('Toaster request failed: {\n${body.trimRight()}\n}');
      print('${response.statusCode} response: ${response.body}');
      return responseBody;
    }
    return responseBody['data'];
  }

  static String getError(Map<String, dynamic> response) {
    var errors = response['errors'];
    return errors != null ? (errors as List)[0]['message'] : null;
  }

  static Future<void> logError(String type, String desc) async {
    String query = """
      mutation {
        addSystemError(errorType: "$type", description: "$desc") {
          id
        }
      }
    """;
    await get(query);
  }
}
