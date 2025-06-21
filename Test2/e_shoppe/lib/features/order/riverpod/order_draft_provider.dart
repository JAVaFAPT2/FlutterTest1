import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/data/models/cart_item.dart';
import 'package:e_shoppe/data/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderDraft {
  final User? customer;
  final List<CartItem> items;
  final String? note;
  final String? country;
  final String? city;
  final String? address;
  final String? phone;
  final String? customerName;
  final String? customerEmail;
  final String? paymentMethod;
  final double discount;
  final String? shippingMethod;
  final String? extraService;
  final String? zipCode;

  // --- Computed amounts ---
  double get subtotal => items.fold(0, (prev, e) => prev + e.subtotal);
  static const double vatRate = 0.1; // 10%
  static const double shippingFlat = 50000; // Vnd

  double get vat => subtotal * vatRate;
  double get shippingFee => items.isEmpty ? 0 : shippingFlat;
  double get total => subtotal - discount + vat + shippingFee;

  const OrderDraft({
    this.customer,
    this.items = const [],
    this.note,
    this.country,
    this.city,
    this.address,
    this.phone,
    this.customerName,
    this.customerEmail,
    this.paymentMethod,
    this.discount = 0,
    this.shippingMethod,
    this.extraService,
    this.zipCode,
  });

  OrderDraft copyWith({
    User? customer,
    List<CartItem>? items,
    String? note,
    String? country,
    String? city,
    String? address,
    String? phone,
    String? customerName,
    String? customerEmail,
    String? paymentMethod,
    double? discount,
    String? shippingMethod,
    String? extraService,
    String? zipCode,
  }) {
    return OrderDraft(
      customer: customer ?? this.customer,
      items: items ?? this.items,
      note: note ?? this.note,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discount: discount ?? this.discount,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      extraService: extraService ?? this.extraService,
      zipCode: zipCode ?? this.zipCode,
    );
  }
}

class OrderDraftNotifier extends StateNotifier<OrderDraft> {
  OrderDraftNotifier() : super(const OrderDraft());

  void setCustomer(User customer) {
    state = state.copyWith(
      customer: customer,
      phone: state.phone ?? customer.phone,
      address: state.address ?? customer.address,
      customerName: customer.name,
      customerEmail: customer.email,
    );
  }

  void clearCustomer() {
    state = state.copyWith(customer: null);
  }

  void addItem(CartItem item) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == item.product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(item);
    }
    state = state.copyWith(items: items);
  }

  void updateItem(CartItem item) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.product.id == item.product.id);
    if (index >= 0) {
      items[index] = item;
      state = state.copyWith(items: items);
    }
  }

  void changeItemQty(int productId, int delta) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx >= 0) {
      final newQty = ((items[idx].quantity + delta).clamp(1, 100)).toInt();
      items[idx] = items[idx].copyWith(quantity: newQty);
      state = state.copyWith(items: items);
    }
  }

  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((e) => e.product.id != productId).toList(),
    );
  }

  /// Replace entire items list, e.g. when syncing from CartBloc.
  void setItems(List<CartItem> items) {
    final discountTotal = items.fold(0.0, (sum, e) => sum + e.discountValue);
    state = state.copyWith(items: items, discount: discountTotal);
  }

  void clear() {
    state = const OrderDraft();
  }

  // --- field setters ---
  void setCountry(String? country) {
    state = state.copyWith(country: country);
  }

  void setCity(String? city) {
    state = state.copyWith(city: city);
  }

  void setAddress(String? address) {
    state = state.copyWith(address: address);
  }

  void setPhone(String? phone) {
    state = state.copyWith(phone: phone);
  }

  void setCustomerName(String? name) {
    state = state.copyWith(customerName: name);
  }

  void setCustomerEmail(String? email) {
    state = state.copyWith(customerEmail: email);
  }

  void setPaymentMethod(String? method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setShippingMethod(String? method) {
    state = state.copyWith(shippingMethod: method);
  }

  void setExtraService(String? service) {
    state = state.copyWith(extraService: service);
  }

  void setZipCode(String? code) {
    state = state.copyWith(zipCode: code);
    if (code == null || code.isEmpty) return;

    _lookupZipAsync(code);
  }

  Future<void> _lookupZipAsync(String code) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'postalcode': code,
        'countrycodes': 'vn', // Vietnam; adjust if needed
        'format': 'json',
        'addressdetails': '1',
      });

      final res = await http.get(
        uri,
        headers: {'User-Agent': 'e_shoppe_app/1.0 (your_email@example.com)'},
      );

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final addrDetails = first['address'] as Map<String, dynamic>?;
          final city = addrDetails?['state'] ?? addrDetails?['city'];
          final country = addrDetails?['country'];

          state = state.copyWith(
            city: city as String?,
            country: country as String?,
          );
        }
      }
    } catch (_) {
      // silently ignore errors / no results
    }
  }
}

final orderDraftProvider =
    StateNotifierProvider<OrderDraftNotifier, OrderDraft>((ref) {
  return OrderDraftNotifier();
});
