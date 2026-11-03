import 'package:flutter/material.dart';

import '../../domain/entities/person_entity.dart';
import '../pages/person_detail_screen.dart';

class PersonImage extends StatelessWidget {
  const PersonImage({super.key, required this.person, this.fit = BoxFit.cover});
  final PersonEntity person;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => Image.network(
    person.image,
    fit: fit,
    semanticLabel: person.name,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    errorBuilder: (context, error, stack) => const ColoredBox(
      color: Color(0xff3c3e44),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          semanticLabel: 'Image unavailable',
        ),
      ),
    ),
  );
}

class PersonStatus extends StatelessWidget {
  const PersonStatus({super.key, required this.person});
  final PersonEntity person;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: switch (person.status.toLowerCase()) {
            'alive' => const Color(0xff55cc44),
            'dead' => const Color(0xffd63d2e),
            _ => const Color(0xff9e9e9e),
          },
        ),
      ),
      const SizedBox(width: 7),
      Expanded(child: Text('${person.status} - ${person.species}')),
    ],
  );
}

class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.person});
  final PersonEntity person;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xff3c3e44),
    borderRadius: BorderRadius.circular(8),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PersonDetailScreen(person: person),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width < 360 ? 115 : 140,
              child: PersonImage(person: person),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    PersonStatus(person: person),
                    const SizedBox(height: 14),
                    const Text(
                      'Last known location:',
                      style: TextStyle(color: Color(0xffb0b0b0), fontSize: 12),
                    ),
                    Text(person.location),
                    const SizedBox(height: 10),
                    const Text(
                      'Origin:',
                      style: TextStyle(color: Color(0xffb0b0b0), fontSize: 12),
                    ),
                    Text(person.origin),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
