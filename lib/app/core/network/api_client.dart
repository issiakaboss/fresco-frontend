import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fresco_shop/app/common/controllers/socket_controller.dart';
import 'package:fresco_shop/app/common/controllers/user_controller.dart';
import 'package:fresco_shop/app/data/models/token.dart';
import 'package:fresco_shop/app/data/repositories/user_repository.dart';
import 'package:fresco_shop/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

class ApiClient {
  // Headers with or without authentication
  static Map<String, String> headers({bool auth = false}) {
    String? lang = Get.locale?.languageCode;
    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'accept-language': lang ?? 'fr',
    };

    if (auth) {
      String? token = Token.getToken();
      if (token != null && token.isNotEmpty) {
        header['Authorization'] = 'Bearer $token';
      }
    }

    return header;
  }

  /// Decode response body safely (once)
  static dynamic _decodeBody(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      debugPrint(
        '[API] Invalid JSON (status ${response.statusCode}): ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
      );
      return null;
    }
  }

  /// Extract error message from decoded body
  static String _extractMessage(dynamic body, String fallback) {
    if (body is Map<String, dynamic>) {
      return body["message"]?.toString() ?? fallback;
    }
    return fallback;
  }

  // Process API response
  static dynamic processResponse(http.Response response) {
    final int status = response.statusCode;

    switch (status) {
      case 200:
      case 201:
        final body = _decodeBody(response);
        if (body == null) {
          throw ApiException('Réponse invalide du serveur', null, null, status);
        }
        return body;

      case 401:
        _handleUnauthorized();
        throw ApiException(
          'Session expirée, veuillez vous reconnecter',
          null,
          null,
          status,
        );

      case 503:
        final body = _decodeBody(response);
        final String message = _extractMessage(
          body,
          'Service temporairement indisponible',
        );
        throw ServiceUnavailableException(message);

      case 500:
        throw ApiException('Erreur de serveur', null, null, status);

      default:
        final body = _decodeBody(response);
        throw ApiException(
          _extractMessage(body, 'Erreur serveur ($status)'),
          null,
          null,
          status,
        );
    }
  }

  static void _handleUnauthorized() {
    Get.find<UserRepository>().clearUser();
    if (Get.isRegistered<UserController>()) {
      UserController.to.userRx.value = null;
    }

    if (Get.isRegistered<SocketController>()) {
      SocketController socketController = Get.find<SocketController>();
      if (socketController.echo != null) {
        try {
          var channels = socketController.echo!.connector.channels.values
              .toList();
          for (var chanel in channels) {
            socketController.echo!.connector.leaveChannel(chanel.name);
          }
          socketController.echo!.connector.disconnect();
        } catch (e) {}
        socketController.echo = null;
      }
    }
    Get.offAllNamed(Routes.LOGIN);
  }
}
