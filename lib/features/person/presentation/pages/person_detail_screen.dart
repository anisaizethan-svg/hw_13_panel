import 'package:flutter/material.dart';

import '../../domain/entities/person_entity.dart';
import '../widgets/person_card.dart';

class PersonDetailScreen extends StatelessWidget {
  const PersonDetailScreen({super.key, required this.person});
  final PersonEntity person;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(person.name)),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(aspectRatio: 1, child: PersonImage(person: person)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PersonStatus(person: person),
                    const SizedBox(height: 24),
                    _field('Gender', person.gender),
                    _field('Species', person.species),
                    _field('Origin', person.origin),
                    _field('Last known location', person.location),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 18)),
      ],
    ),
  );
}
