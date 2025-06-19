import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_shoppe/features/search/search_page.dart';
import 'package:e_shoppe/features/search/riverpod/search_notifier.dart';
import 'package:e_shoppe/data/models/product.dart';
import 'package:e_shoppe/data/repositories/product_repository.dart';
import 'package:e_shoppe/services/api_client.dart';

class _FakeProductRepository extends ProductRepository {
  _FakeProductRepository() : super(ApiClient());

  @override
  Future<List<Product>> fetchProducts(
      {String? query, int? page, int limit = 20}) async {
    // 30 items
    return List.generate(
      30,
      (i) => Product(
        id: i,
        title: 'Item $i',
        description: 'Desc',
        imageUrl: 'https://example.com/$i.png',
        price: i.toDouble(),
      ),
    );
  }
}

void main() {
  testWidgets('SearchPage grid columns adapt to screen size', (tester) async {
    final fakeRepo = _FakeProductRepository();
    final notifier = SearchNotifier(fakeRepo);

    // Start with mobile size
    await tester.binding.setSurfaceSize(const Size(360, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );

    // allow fetch
    await tester.pump(const Duration(seconds: 1));

    // Mobile width 360 should yield 1 column (list-like)
    final gridFinder = find.byType(GridView);
    expect(gridFinder, findsOneWidget);
    final grid = tester.widget<GridView>(gridFinder);
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, lessThan(3));

    // Rebuild with desktop size
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pump();

    // Expect more columns (>=3)
    final grid2 = tester.widget<GridView>(gridFinder);
    final delegate2 =
        grid2.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate2.crossAxisCount, greaterThan(1));
  });
}
