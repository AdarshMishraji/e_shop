import 'package:http/http.dart' as http;

class Http {
  static const String baseURL =
      'https://flutter-practice-534fd-default-rtdb.firebaseio.com';
  static const String API_KEY = 'AIzaSyCboBWyzFAyF6l57DLEWEp1_aNT9oD7Fso';
  static const String authBaseURL =
      'https://identitytoolkit.googleapis.com/v1/accounts';

  static Future<http.Response> get(String baseUrl, String endpoint) {
    return http.get(Uri.parse(baseUrl + endpoint));
  }

  static Future<http.Response> post(
      String baseUrl, String? endpoint, Object? body) {
    return http.post(Uri.parse(baseUrl + (endpoint ?? '')), body: body);
  }

  static Future<http.Response> put(
      String baseUrl, String? endpoint, Object? body) {
    return http.put(Uri.parse(baseUrl + (endpoint ?? '')), body: body);
  }

  static Future<http.Response> patch(
      String baseUrl, String? endpoint, Object? body) {
    return http.patch(Uri.parse(baseUrl + (endpoint ?? '')), body: body);
  }

  static Future<http.Response> delete(
      String baseUrl, String? endpoint, Object? body) {
    return http.delete(Uri.parse(baseUrl + (endpoint ?? '')), body: body);
  }

  static Future<http.Response> head(String baseUrl, String endpoint) {
    return http.head(Uri.parse(baseUrl + endpoint));
  }
}
