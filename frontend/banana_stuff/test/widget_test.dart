// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:banana_stuff/main.dart'; // Ensure this path is correct.

void main() {
  testWidgets('Upload button and initial state test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester
        .pumpWidget(MyApp()); // Replace with the correct main widget name.

    // Verify that the initial text is 'No image selected.'
    expect(find.text('No image selected.'), findsOneWidget);

    // Verify that the 'Select Image' button is present.
    expect(find.text('Select Image'), findsOneWidget);

    // Tap the 'Select Image' button (won't open the picker in tests).
    await tester.tap(find.text('Select Image'));
    await tester.pump();
  });
}
