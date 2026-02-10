import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pull_request/models/platform.dart';
import 'package:pull_request/widgets/platform_card.dart';

void main() {
  group('PlatformCard', () {
    const testPlatform = Platform(
      id: 'test',
      name: 'Test Platform',
      iconPath: 'assets/icons/spotify_icon.png',
    );

    testWidgets('displays platform name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlatformCard(platform: testPlatform)),
        ),
      );

      expect(find.text('Test Platform'), findsOneWidget);
    });

    testWidgets('displays platform icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlatformCard(platform: testPlatform)),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformCard(
              platform: testPlatform,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlatformCard));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformCard(
              platform: testPlatform,
              isDisabled: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlatformCard));
      expect(tapped, isFalse);
    });

    testWidgets('shows selected state styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformCard(platform: testPlatform, isSelected: true),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PlatformCard),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('shows disabled state with reduced opacity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformCard(platform: testPlatform, isDisabled: true),
          ),
        ),
      );

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(PlatformCard),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacity.opacity, lessThan(1.0));
    });
  });
}
