import 'dart:async';
import 'dart:convert';

import 'package:butter/config/config.dart';
import 'package:http/http.dart' as http;

import 'log.dart';

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
    var responseBody;
    try { responseBody = json.decode(response.body); } catch (e, stack) { Log.error('$e, $stack'); }
    if (response.statusCode != 200 || responseBody == null || responseBody['errors'] != null) {
      Log.error('Toaster request failed: {\n${body.trimRight()}\n}');
      Log.error('${response.statusCode} response: ${response.body}');
      return Map<String, dynamic>();
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
