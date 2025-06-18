import 'dart:convert';

import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.address,
  });

  final String id;
  final String email;
  final String name;
  final String? address;

  factory User.empty() => const User(id: '', email: '', name: '');

  bool get isEmpty => id.isEmpty;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'address': address,
      };

  String toRawJson() => jsonEncode(toJson());

  factory User.fromRawJson(String source) =>
      User.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, email, name, address];
}
