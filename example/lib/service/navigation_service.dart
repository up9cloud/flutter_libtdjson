import 'package:flutter/material.dart';

import '../page/mod.dart' show CodePage, LoginPage, HomePage, LogoutPage;
import '../service/mod.dart' show LogService;

class NavigationService {
  static const String LOGIN = '/login';
  static const String CODE = '/code';
  static const String END = '/end';
  static Function(dynamic s) _log = LogService.build('NavigationService');

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    _log('onGenerateRoute: $settings');
    switch (settings.name) {
      case NavigationService.LOGIN:
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
        );
      case NavigationService.CODE:
        return MaterialPageRoute(
          builder: (_) => CodePage(),
        );
      case NavigationService.END:
        return MaterialPageRoute(
          builder: (_) => LogoutPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
    }
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Future<dynamic> goTo(String routeName, {Object? arguments}) {
    _log('goTo: $routeName');
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }
}
