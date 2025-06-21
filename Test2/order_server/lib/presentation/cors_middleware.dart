import 'package:shelf/shelf.dart';

Middleware cors() {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PATCH, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  };

  Response addCorsHeaders(Response res) => res.change(headers: corsHeaders);

  return (innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }
      final response = await innerHandler(request);
      return addCorsHeaders(response);
    };
  };
}
