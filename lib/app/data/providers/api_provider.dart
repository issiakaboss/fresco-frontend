import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

class ApiProvider {
  static const int timeOutDuration = 200;

  /// Centralized request handler — all HTTP methods pass through here
  static Future<dynamic> _executeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      var response = await request().timeout(
        const Duration(seconds: timeOutDuration),
      );
      return ApiClient.processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', '');
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time', '');
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[ApiProvider] Unexpected error: $e');
      throw FetchDataException('Erreur inattendue: $e', '');
    }
  }

  static Future<dynamic> get({
    bool auth = true,
    required String apiURL,
    bool isPhone = false,
  }) {
    return _executeRequest(() => http.get(
          Uri.parse(ApiClient.baseUrl + apiURL),
          headers: ApiClient.headers(auth: auth),
        ));
  }

  static Future<dynamic> post({
    required bool auth,
    required Map<String, dynamic> data,
    required String apiURL,
    bool isPhone = false,
  }) {
    return _executeRequest(() => http.post(
          Uri.parse(ApiClient.baseUrl + apiURL),
          body: jsonEncode(data),
          headers: ApiClient.headers(auth: auth),
        ));
  }

  static Future<dynamic> put({
    required bool auth,
    required String apiURL,
    required Map<String, dynamic> data,
    bool isPhone = false,
  }) {
    return _executeRequest(() => http.put(
          Uri.parse(ApiClient.baseUrl + apiURL),
          headers: ApiClient.headers(auth: auth),
          body: jsonEncode(data),
        ));
  }

  static Future<dynamic> delete({
    bool auth = false,
    required String apiURL,
    bool isPhone = false,
  }) {
    return _executeRequest(() => http.delete(
          Uri.parse(ApiClient.baseUrl + apiURL),
          headers: ApiClient.headers(auth: auth),
        ));
  }

  static Future<dynamic> postMultipart({
    required bool auth,
    required String apiURL,
    required File file,
    required String fileKey,
    Map<String, String>? fields,
    bool isPhone = false,
  }) async {
    try {
       
      var uri = Uri.parse(ApiClient.baseUrl + apiURL);
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(ApiClient.headers(auth: auth));
      if (fields != null) {
        request.fields.addAll(fields);
      }
      var multipartFile = await http.MultipartFile.fromPath(
        fileKey, 
        file.path,
      );
      request.files.add(multipartFile);
      var streamedResponse = await request.send().timeout(const Duration(seconds: timeOutDuration));
      var response = await http.Response.fromStream(streamedResponse);

      return ApiClient.processResponse(response);
      
    } on SocketException {
      throw FetchDataException('No Internet connection', '');
    } on TimeoutException {
      throw ApiNotRespondingException('API not responded in time', '');
    }
  }
}
