import 'package:flutter/widgets.dart';

/// Simple responsive helper with three break-points.
class Responsive {
  static const double _tabletMinWidth = 600;
  static const double _desktopMinWidth = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _tabletMinWidth;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= _tabletMinWidth && w < _desktopMinWidth;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopMinWidth;

  /// Returns 1 (mobile), 2 (tablet) or 4 (desktop) for typical grid counts.
  static int gridColumnCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Returns a suitable max content width for centered layouts.
  static double maxBodyWidth(BuildContext context) {
    if (isDesktop(context)) return 1000;
    if (isTablet(context)) return 700;
    return double.infinity;
  }
}
