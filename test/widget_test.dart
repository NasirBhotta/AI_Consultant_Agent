import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agent_app/src/core/constants/app_constants.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('renders home page structure guidance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomePage(),
      ),
    );

    expect(find.text('Project foundation is ready'), findsOneWidget);
    expect(find.text('Startup flow'), findsOneWidget);
    expect(find.text(AppConstants.firebaseSetupHint), findsNothing);
  });
}
