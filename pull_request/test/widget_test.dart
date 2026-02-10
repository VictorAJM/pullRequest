import 'package:flutter_test/flutter_test.dart';

import 'package:pull_request/app.dart';

void main() {
  testWidgets('PullRequest home screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('PullRequest'), findsOneWidget);
    expect(find.text('Move your music between'), findsOneWidget);
    expect(find.text('platforms in seconds.'), findsOneWidget);
    expect(find.text('Start Transfer'), findsOneWidget);
  });
}
