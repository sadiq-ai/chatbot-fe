import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class NetworkCall {
  static String get baseUrl => '34.126.116.76:4000';
  // static String get baseUrl => '172.16.56.48:4000';

  // Get Request with optional jwt token
  Future<Map<String, dynamic>?> get({
    required String route,
    String? jwt,
  }) async {
    print('API-Call: GET $route');
    // get params from route after the ? sign
    Map<String, String>? paramsMap;
    if (route.contains('?')) {
      final String params = route.split('?')[1];
      route = route.split('?')[0];
      paramsMap = Uri.splitQueryString(params);
    }
    try {
      http.Response response = await http.get(
        Uri.https(baseUrl, route, paramsMap),
        headers: <String, String>{
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $jwt',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      print(e);
      return null;
    } finally {
      print('API Call Completed');
    }
  }

  // Post Request with optional jwt token
  Future<Map<String, dynamic>?> post({
    required String route,
    required Object payload,
    String? jwt,
  }) async {
    print('API-Call: POST $route');
    try {
      http.Response response = await http.post(
        Uri.https(baseUrl, route),
        headers: <String, String>{
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $jwt',
        },
        body: json.encode(payload),
      );
      print('Api response: $response');
      return json.decode(response.body);
    } catch (e) {
      print(e);
      return null;
    } finally {
      print('API Call Completed');
    }
  }

  // Delete Request with optional jwt token
  Future<Map<String, dynamic>?> delete({
    required String route,
    String? jwt,
  }) async {
    print('API-Call: DELETE $route');
    try {
      http.Response response = await http.delete(
        Uri.https(baseUrl, route),
        headers: <String, String>{
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $jwt',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      print(e);
      return null;
    } finally {
      print('API Call Completed');
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
