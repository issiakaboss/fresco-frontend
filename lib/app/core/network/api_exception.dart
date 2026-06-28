class ApiException implements Exception {
  final String? message;
  final String? prefix;
  final String? url;
  final int? statusCode;

  ApiException([this.message, this.prefix, this.url, this.statusCode]);

  @override
  String toString() =>
      '${prefix ?? 'ApiException'}${statusCode != null ? ' [$statusCode]' : ''}: ${message ?? 'Unknown error'}';
}

class FetchDataException extends ApiException {
  FetchDataException([String? message, String? url])
      : super(message, 'FetchDataException', url);
}

class ApiNotRespondingException extends ApiException {
  ApiNotRespondingException([String? message, String? url])
      : super(message, 'ApiNotRespondingException', url);
}

class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException([String? message])
      : super(message, 'ServiceUnavailableException', null, 503);
}
