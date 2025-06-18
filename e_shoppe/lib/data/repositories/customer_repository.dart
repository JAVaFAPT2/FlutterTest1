import 'package:dio/dio.dart';
import '../models/user.dart';

class CustomerRepository {
  CustomerRepository({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;
  static const _baseUrl = 'https://dummyjson.com';

  Future<List<User>> searchCustomers(String query) async {
    if (query.isEmpty) return [];
    final response =
        await _dio.get('$_baseUrl/users/search', queryParameters: {'q': query});
    if (response.statusCode != 200) throw Exception('Failed');
    final List<dynamic> usersJson = (response.data['users'] as List<dynamic>);
    return usersJson
        .map((e) => User.fromJsonDummy(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _dio.close(force: true);
}
