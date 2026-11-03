import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:panel_13_arc/main.dart' as app;
import 'package:panel_13_arc/locator_service.dart';
import 'package:panel_13_arc/features/person/domain/repositories/person_repository.dart';
import 'package:panel_13_arc/features/person/presentation/widgets/person_card.dart';
import 'package:panel_13_arc/features/person/presentation/pages/person_detail_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real API list, images, pagination, search, details and navigation',
    (tester) async {
      await app.main();
      Future<void> waitFor(Finder finder) async {
        for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        if (finder.evaluate().isEmpty) {
          debugPrint(
            'VISIBLE TEXT: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList()}',
          );
          await binding.takeScreenshot('failure');
        }
        expect(finder, findsWidgets);
      }

      await waitFor(find.text('Rick Sanchez'));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.byType(PersonCard), findsWidgets);
      final image = tester.widgetList<Image>(find.byType(Image)).first;
      final info = await image.image
          .resolve(const ImageConfiguration())
          .firstImage
          .timeout(const Duration(seconds: 20));
      expect(info.image.width, greaterThan(0));
      info.dispose();
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('characters');
      await tester.tap(find.text('Rick Sanchez'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonDetailScreen), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      await binding.takeScreenshot('detail');
      await tester.pageBack();
      await tester.pumpAndSettle();
      // Scroll beyond the original 20 API records.
      for (var i = 0; i < 24; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 500));
        if (tester
            .widgetList<PersonCard>(find.byType(PersonCard))
            .any((card) => card.person.id > 20)) {
          break;
        }
      }
      await tester.pumpAndSettle();
      final cards = tester.widgetList<PersonCard>(find.byType(PersonCard));
      expect(cards.any((card) => card.person.id > 20), isTrue);
      await tester.tap(find.byTooltip('Search characters'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'morty');
      for (var attempt = 0; attempt < 4; attempt++) {
        for (var i = 0; i < 80; i++) {
          await tester.pump(const Duration(milliseconds: 250));
          if (find.byType(PersonCard).evaluate().isNotEmpty ||
              find.text('Retry').evaluate().isNotEmpty) {
            break;
          }
        }
        if (find.byType(PersonCard).evaluate().isNotEmpty) {
          break;
        }
        if (find.text('Retry').evaluate().isNotEmpty) {
          await tester.pump(const Duration(seconds: 3));
          await tester.tap(find.text('Retry'));
        }
      }
      await waitFor(find.byType(PersonCard));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<PersonCard>(find.byType(PersonCard).first)
            .person
            .name
            .toLowerCase(),
        contains('morty'),
      );
      await binding.takeScreenshot('search');
      await tester.tap(find.byType(PersonCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(PersonDetailScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Search for a character by name'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'zzzznonexistentcharacterzzzz',
      );
      await waitFor(find.textContaining('No characters found'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Characters'), findsOneWidget);
      final saved = await sl<PersonRepository>().getAllPersons(1);
      expect(saved.persons.length, 20);
      expect(tester.takeException(), isNull);
    },
  );
}

extension on ImageStream {
  Future<ImageInfo> get firstImage {
    final completer = Completer<ImageInfo>();
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (image, _) {
        removeListener(listener);
        completer.complete(image);
      },
      onError: (Object e, StackTrace? s) {
        removeListener(listener);
        completer.completeError(e, s);
      },
    );
    addListener(listener);
    return completer.future;
  }
}
