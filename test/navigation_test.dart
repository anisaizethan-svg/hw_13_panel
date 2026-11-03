import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_13_arc/features/person/domain/entities/person_entity.dart';
import 'package:panel_13_arc/features/person/presentation/pages/person_detail_screen.dart';
import 'package:panel_13_arc/features/person/presentation/widgets/person_card.dart';

void main() {
  testWidgets(
    'long character cards fit narrow screens and open scrollable details',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const person = PersonEntity(
        id: 1,
        name: 'A character with a very long name',
        status: 'unknown',
        species: 'Humanoid',
        gender: 'unknown',
        image: '',
        origin: 'A very distant planet with a long name',
        location: 'Citadel of Ricks',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: PersonCard(person: person),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('unknown - Humanoid'), findsOneWidget);
      await tester.tap(find.text(person.name));
      await tester.pumpAndSettle();
      expect(find.byType(PersonDetailScreen), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gender'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(PersonDetailScreen), findsNothing);
    },
  );
}
