import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String domain = env['API_URL'];

Future httpPost(String route, [dynamic data]) async {
  var dataStr = jsonEncode(data);
  var url = "$domain/$route";
  var result = await http
      .post(url, body: dataStr, headers: {"Content-Type": "application/json"});
  return jsonDecode(result.body);
}

Future httpGet(String route, [dynamic data]) async {
  var url = "$domain/$route";
  var result =
      await http.get(url, headers: {"Content-Type": "application/json"});
  return jsonDecode(result.body);
}
