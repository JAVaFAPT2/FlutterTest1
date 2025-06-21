import 'package:flutter_test/flutter_test.dart';
import 'package:e_shoppe/features/search/riverpod/search_notifier.dart';
import 'package:e_shoppe/data/models/product.dart';
import 'package:e_shoppe/data/repositories/product_repository.dart';
import 'package:e_shoppe/services/api_client.dart';

class _FakeProductRepository extends ProductRepository {
  _FakeProductRepository() : super(ApiClient());

  @override
  Future<List<Product>> fetchProducts(
      {String? query, int? page, int limit = 20}) async {
    // Generate 45 dummy products
    return List.generate(
      45,
      (i) => Product(
        id: i,
        title: 'Item $i',
        description: 'Desc $i',
        imageUrl: 'https://example.com/$i.png',
        price: i.toDouble(),
      ),
    );
  }
}

void main() {
  group('SearchNotifier pagination', () {
    late SearchNotifier notifier;

    setUp(() {
      notifier = SearchNotifier(_FakeProductRepository());
    });

    test('initial fetch returns first page', () async {
      await notifier.fetch('');
      expect(notifier.state.products.length, 20);
      expect(notifier.state.hasReachedMax, isFalse);
    });

    test('loadMore adds next page and eventually reaches max', () async {
      await notifier.fetch('');
      notifier.loadMore();
      expect(notifier.state.products.length, 40);
      expect(notifier.state.hasReachedMax, isFalse);

      notifier.loadMore();
      expect(notifier.state.products.length, 45);
      expect(notifier.state.hasReachedMax, isTrue);
    });
  });
}
