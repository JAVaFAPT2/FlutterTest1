import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Adds Bearer JWT verification. If token invalid returns 401.
Middleware jwtMiddleware() {
  final secret = Platform.environment['JWT_SECRET'] ?? 'secret';
  return (innerHandler) {
    return (Request request) async {
      // Public endpoints that don't require auth. Add more as needed.
      final isPublic = (request.method == 'GET' &&
              request.url.path.startsWith('products')) ||
          (request.method == 'POST' && request.url.path.startsWith('orders'));

      if (isPublic) {
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
