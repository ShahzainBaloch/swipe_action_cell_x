import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swipe_action_cell_x/swipe_action_cell_x.dart';

void main() {
  testWidgets('SwipeActionCell renders child content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SwipeActionCell(
            child: SizedBox(
              width: 300,
              height: 60,
              child: Text('Inbox Item 1'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Inbox Item 1'), findsOneWidget);
  });

  testWidgets('SwipeActionCell reveals right actions on left swipe and triggers tap',
      (tester) async {
    bool deleteTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeActionCell(
            rightActions: [
              SwipeAction(
                title: 'Delete',
                icon: const Icon(Icons.delete),
                backgroundColor: Colors.red,
                onTap: () => deleteTapped = true,
              ),
            ],
            child: const SizedBox(
              width: 400,
              height: 80,
              child: Text('Slide Me'),
            ),
          ),
        ),
      ),
    );

    // Drag from right to left
    await tester.drag(find.text('Slide Me'), const Offset(-120, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);

    // Tap the delete button
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deleteTapped, isTrue);
  });

  testWidgets('SwipeActionController can programmatically open and close',
      (tester) async {
    final controller = SwipeActionController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeActionCell(
            controller: controller,
            leftActions: [
              SwipeAction(
                title: 'Archive',
                icon: const Icon(Icons.archive),
                backgroundColor: Colors.blue,
                onTap: () {},
              ),
            ],
            child: const SizedBox(
              width: 400,
              height: 80,
              child: Text('Programmatic Item'),
            ),
          ),
        ),
      ),
    );

    expect(controller.isOpen, isFalse);

    controller.openLeft();
    await tester.pumpAndSettle();

    expect(controller.isOpen, isTrue);
    expect(controller.state, equals(SwipeActionState.openLeft));

    controller.close();
    await tester.pumpAndSettle();

    expect(controller.isOpen, isFalse);
    expect(controller.state, equals(SwipeActionState.closed));
  });
}
