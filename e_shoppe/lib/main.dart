import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/firebase_options.dart' as firebase_options;
import 'package:e_shoppe/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:e_shoppe/data/repositories/auth_repository.dart';
import 'package:e_shoppe/features/auth/bloc/auth_bloc.dart';
import 'package:e_shoppe/features/auth/login_page.dart';
import 'package:e_shoppe/features/home/home_shell.dart';
import 'package:e_shoppe/features/cart/bloc/cart_bloc.dart';
import 'package:e_shoppe/theme/app_theme.dart';
import 'package:e_shoppe/features/profile/profile_page.dart';
import 'package:e_shoppe/features/cart/cart_page.dart';
import 'package:e_shoppe/features/search/search_page.dart';
import 'package:e_shoppe/features/order/order_list_page.dart';
import 'package:e_shoppe/features/order/order_create_page.dart';
import 'package:e_shoppe/features/order/product_select_page.dart';
import 'package:e_shoppe/features/order/shipping_info_page.dart';
import 'package:e_shoppe/features/order/order_confirm_page.dart';
import 'package:e_shoppe/features/order/order_success_page.dart';
import 'package:e_shoppe/features/order/order_failure_page.dart';
import 'package:e_shoppe/features/order/order_detail_page.dart';
import 'package:e_shoppe/features/demo/figma_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (using default options for now)
  await Firebase.initializeApp(
      options: firebase_options.DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Filter out the duplicate-keydown assertion that happens on some Windows keyboards.
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorStr = details.exceptionAsString();
    if (details.exception is AssertionError &&
        errorStr.contains('!_pressedKeys.containsKey')) {
      debugPrint('Ignored duplicate KeyDown assertion');
      return;
    }
    FlutterError.presentError(details);
  };

  // Also catch it at the dispatcher/zone level (async errors).
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    if (error is AssertionError &&
        error.toString().contains('!_pressedKeys.containsKey')) {
      debugPrint('Ignored duplicate KeyDown assertion (dispatcher)');
      return true; // handled
    }
    return false; // allow normal error handling
  };

  final navigatorKey = GlobalKey<NavigatorState>();
  runApp(ProviderScope(child: EShoppeApp(navigatorKey: navigatorKey)));

  // init notifications
  NotificationService.instance.init(navigatorKey);
}

class EShoppeApp extends StatelessWidget {
  const EShoppeApp({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(
            create: (_) => AuthBloc(authRepository)..add(const AppStarted())),
      ],
      child: RepositoryProvider.value(
        value: authRepository,
        child: Builder(builder: (context) {
          // nested so AuthBloc accessible
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Consumer(builder: (context, ref, _) {
                return MaterialApp(
                  title: 'E-Shoppe',
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: ThemeMode.light,
                  home: () {
                    if (state.status == AuthStatus.authenticated) {
                      return const HomeShell();
                    } else if (state.status == AuthStatus.unauthenticated) {
                      return const LoginPage();
                    } else {
                      return const Scaffold(
                          body: Center(child: CircularProgressIndicator()));
                    }
                  }(),
                  navigatorKey: navigatorKey,
                  routes: {
                    '/profile': (_) => const ProfilePage(),
                    '/search': (_) => const SearchPage(),
                    '/cart': (_) => const CartPage(),
                    '/orders': (_) => const OrderListPage(),
                    '/order/create': (_) => const OrderCreatePage(),
                    '/order/select-product': (_) => const ProductSelectPage(),
                    '/order/shipping-info': (_) => const ShippingInfoPage(),
                    '/order/confirm': (_) => const OrderConfirmPage(),
                    '/order/success': (_) => const OrderSuccessPage(),
                    '/order/failure': (_) => const OrderFailurePage(),
                    '/order/detail': (_) => const OrderDetailPage(),
                    '/v2': (_) => const FigmaHomePage(),
                  },
                );
              });
            },
          );
        }),
      ),
    );
  }
}
