import 'package:flutter_test/flutter_test.dart';
import 'package:e_shoppe/shared/responsive.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('Responsive.gridColumnCount returns correct values',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(500, 800)),
        child: Builder(builder: (context) {
          expect(Responsive.gridColumnCount(context), 1);
          return const Placeholder();
        }),
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 800)),
        child: Builder(builder: (context) {
          expect(Responsive.gridColumnCount(context), 2);
          return const Placeholder();
        }),
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1300, 800)),
        child: Builder(builder: (context) {
          expect(Responsive.gridColumnCount(context), 4);
          return const Placeholder();
        }),
      ),
    );
  });
}
