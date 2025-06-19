import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.products = const [],
    this.hasReachedMax = false,
    this.page = 1,
    this.error,
  });

  final SearchStatus status;
  final List<Product> products;
  final bool hasReachedMax;
  final int page;
  final String? error;

  SearchState copyWith({
    SearchStatus? status,
    List<Product>? products,
    bool? hasReachedMax,
    int? page,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._repo) : super(const SearchState()) {
    // start with empty fetch
    fetch('');
  }

  final ProductRepository _repo;

  static const int _perPage = 20;

  List<Product> _all = const [];
  String _lastQuery = '';

  // Expose debounced search
  late final _querySubject = BehaviorSubject<String>()..listen(_onQuery);

  void onQueryChanged(String q) {
    _querySubject.add(q);
  }

  Future<void> _onQuery(String q) async {
    if (q == _lastQuery) return;
    _lastQuery = q;
    await fetch(q);
  }

  Future<void> fetch(String query) async {
    state = state.copyWith(status: SearchStatus.loading);
    try {
      _all = await _repo.fetchProducts(query: query);
      final first = _all.take(_perPage).toList();
      state = state.copyWith(
          status: SearchStatus.success,
          products: first,
          page: 1,
          hasReachedMax: first.length >= _all.length);
    } catch (e) {
      state = state.copyWith(status: SearchStatus.failure, error: e.toString());
    }
  }

  void loadMore() {
    if (state.hasReachedMax) return;
    final nextPage = state.page + 1;
    final start = (nextPage - 1) * _perPage;
    final newItems = _all.skip(start).take(_perPage).toList();
    final merged = [...state.products, ...newItems];
    state = state.copyWith(
        products: merged,
        page: nextPage,
        hasReachedMax: merged.length >= _all.length);
  }

  @override
  void dispose() {
    _querySubject.close();
    super.dispose();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return SearchNotifier(repo);
});
