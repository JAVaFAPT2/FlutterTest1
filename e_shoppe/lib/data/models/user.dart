import 'dart:convert';

import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.address,
    this.phone,
  });

  final String id;
  final String email;
  final String name;
  final String? address;
  final String? phone;

  factory User.empty() => const User(id: '', email: '', name: '');

  bool get isEmpty => id.isEmpty;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
      );

  factory User.fromJsonDummy(Map<String, dynamic> json) => User(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: '${json['firstName']} ${json['lastName']}',
        address: json['address']?['address'] as String?,
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'address': address,
        'phone': phone,
      };

  String toRawJson() => jsonEncode(toJson());

  factory User.fromRawJson(String source) =>
      User.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, email, name, address, phone];
}
