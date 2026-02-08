import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/screens/home/widgets/empty_state.dart';

Widget _buildEmptyState({
  String title = 'No Notes',
  String subtitle = 'Create your first note to get started',
  IconData icon = Icons.inbox_outlined,
  Widget? action,
  List<String>? tips,
  Duration tipCycleDuration = const Duration(seconds: 6),
}) {
  return MaterialApp(
    home: Scaffold(
      body: EmptyState(
        title: title,
        subtitle: subtitle,
        icon: icon,
        action: action,
        tips: tips,
        tipCycleDuration: tipCycleDuration,
      ),
    ),
  );
}

void main() {
  testWidgets('EmptyState renders title and subtitle', (tester) async {
    await tester.pumpWidget(_buildEmptyState());

    expect(find.text('No Notes'), findsOneWidget);
    expect(find.text('Create your first note to get started'), findsOneWidget);
  });

  testWidgets('EmptyState renders default icon', (tester) async {
    await tester.pumpWidget(_buildEmptyState());

    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('EmptyState renders custom icon', (tester) async {
    await tester.pumpWidget(
      _buildEmptyState(icon: Icons.search),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsNothing);
  });

  testWidgets('EmptyState renders action button', (tester) async {
    await tester.pumpWidget(
      _buildEmptyState(
        action: ElevatedButton(
          onPressed: () {},
          child: const Text('Create Note'),
        ),
      ),
    );

    expect(find.text('Create Note'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('EmptyState renders without action when not provided', (tester) async {
    await tester.pumpWidget(_buildEmptyState());

    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('EmptyState renders single tip', (tester) async {
    await tester.pumpWidget(
      _buildEmptyState(tips: ['Tip 1']),
    );

    expect(find.text('Tip 1'), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });

  testWidgets('EmptyState renders multiple tips initially', (tester) async {
    await tester.pumpWidget(
      _buildEmptyState(
        tips: ['Tip 1', 'Tip 2', 'Tip 3'],
        tipCycleDuration: const Duration(milliseconds: 100),
      ),
    );

    // First tip should be visible
    expect(find.text('Tip 1'), findsOneWidget);
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
  });

  testWidgets('EmptyState cycles through tips', (tester) async {
    await tester.pumpWidget(
      _buildEmptyState(
        tips: ['Tip 1', 'Tip 2', 'Tip 3'],
        tipCycleDuration: const Duration(milliseconds: 200),
      ),
    );

    // First tip should be visible initially
    expect(find.text('Tip 1'), findsOneWidget);

    // Wait for tip cycle
    await tester.pumpAndSettle(const Duration(milliseconds: 150));
    expect(find.text('Tip 1'), findsOneWidget);

    // Wait for next cycle (fade out, change, fade in)
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    // Tip should have changed to Tip 2
    expect(find.text('Tip 2'), findsOneWidget);
    expect(find.text('Tip 1'), findsNothing);
  });

  testWidgets('EmptyState action button has micro-interaction', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      _buildEmptyState(
        action: ElevatedButton(
          onPressed: () {
            tapped = true;
          },
          child: const Text('Create Note'),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('Create Note')));
    await tester.pump();

    // After tap down, the scale should change (though we can't directly test state)
    // But we can verify the widget responds to gestures
    await gesture.up();
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('EmptyState renders without tips when not provided', (tester) async {
    await tester.pumpWidget(_buildEmptyState());

    expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
  });

  testWidgets('EmptyState handles empty tips list', (tester) async {
    await tester.pumpWidget(
      _buildEmptyState(tips: []),
    );

    expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
  });

  testWidgets('EmptyState uses correct text styles', (tester) async {
    await tester.pumpWidget(_buildEmptyState());

    final titleFinder = find.text('No Notes');
    final subtitleFinder = find.text('Create your first note to get started');

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);

    // Verify widgets are rendered
    final titleWidget = tester.widget<Text>(titleFinder);
    final subtitleWidget = tester.widget<Text>(subtitleFinder);

    expect(titleWidget.textAlign, isNull);
    expect(subtitleWidget.textAlign, TextAlign.center);
  });

  testWidgets('EmptyState center aligns content', (tester) async {
    await tester.pumpWidget(_buildEmptyState());

    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(Column), findsOneWidget);
  });
}
