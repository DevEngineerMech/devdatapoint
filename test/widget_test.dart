import 'package:flutter_test/flutter_test.dart';
import 'package:devdatapoint/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const DevDatapointApp());
    expect(find.byType(DevDatapointApp), findsOneWidget);
  });
}