import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Adds Bearer JWT verification. If token invalid returns 401.
Middleware jwtMiddleware() {
  final secret = Platform.environment['JWT_SECRET'] ?? 'secret';
  return (innerHandler) {
    return (Request request) async {
      // Allow unauthenticated access to the public "GET /products" endpoint.
      // Note: `request.url.path` never contains a leading slash, whereas
      // `requestedUri.path` usually does (e.g. "/products"). Using the
      // slash-less `url.path` avoids mismatches that caused the previous
      // logic to fail and return 401.
      if (request.method == 'GET' &&
          request.url.path.startsWith('products')) {
        return innerHandler(request);
      }

      final auth = request.headers[HttpHeaders.authorizationHeader];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return Response.unauthorized('Missing token');
      }

      final token = auth.substring(7);
      try {
        JWT.verify(token, SecretKey(secret));
      } catch (e) {
        return Response.unauthorized('Invalid token');
      }
      return innerHandler(request);
    };
  };
}
