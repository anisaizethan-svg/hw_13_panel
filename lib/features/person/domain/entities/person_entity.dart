import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  const PersonEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.location,
    required this.origin,
  });
  final int id;
  final String name, status, species, gender, image, location, origin;
  @override
  List<Object?> get props => [
    id,
    name,
    status,
    species,
    gender,
    image,
    location,
    origin,
  ];
}

class PersonPage extends Equatable {
  const PersonPage({
    required this.persons,
    required this.nextPage,
    this.isCached = false,
  });
  final List<PersonEntity> persons;
  final int? nextPage;
  final bool isCached;
  @override
  List<Object?> get props => [persons, nextPage, isCached];
}
