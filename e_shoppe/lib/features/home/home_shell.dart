import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/responsive.dart';
import '../search/search_page.dart';
import '../cart/cart_page.dart';
import '../profile/profile_page.dart';
import '../cart/bloc/cart_bloc.dart';
import '../order/order_list_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final _pages = [
    const SearchPage(),
    const CartPage(),
    const OrderListPage(),
    const ProfilePage()
  ];

  void _onTap(int i) => setState(() => _index = i);

  Widget _cartIcon(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  count.toString(),
                  key: ValueKey(count),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(builder: (context, cartState) {
      final cartCount = cartState.items.length;

      final navItems = [
        const BottomNavigationBarItem(
            icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: _cartIcon(cartCount), label: 'Cart'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.history), label: 'Orders'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Profile'),
      ];

      if (Responsive.isTablet(context) || Responsive.isDesktop(context)) {
        // Side rail
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _onTap,
                labelType: NavigationRailLabelType.selected,
                destinations: [
                  const NavigationRailDestination(
                      icon: Icon(Icons.search), label: Text('Search')),
                  NavigationRailDestination(
                      icon: _cartIcon(cartCount), label: const Text('Cart')),
                  const NavigationRailDestination(
                      icon: Icon(Icons.history), label: Text('Orders')),
                  const NavigationRailDestination(
                      icon: Icon(Icons.person), label: Text('Profile')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: IndexedStack(index: _index, children: _pages))
            ],
          ),
        );
      }

      // Mobile bottom nav
      return Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onTap,
          items: navItems,
        ),
      );
    });
  }
}
