import '../../domain/entities/person_entity.dart';

class PersonModel extends PersonEntity {
  const PersonModel({
    required super.id,
    required super.name,
    required super.status,
    required super.species,
    required super.gender,
    required super.image,
    required super.location,
    required super.origin,
  });
  factory PersonModel.fromJson(Map<String, dynamic> json) {
    String value(dynamic v) => v is String && v.isNotEmpty ? v : 'unknown';
    String place(dynamic v) => v is Map ? value(v['name']) : 'unknown';
    if (json['id'] is! int || json['name'] is! String) {
      throw const FormatException('Invalid character');
    }
    return PersonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: value(json['status']),
      species: value(json['species']),
      gender: value(json['gender']),
      image: json['image'] is String ? json['image'] as String : '',
      location: place(json['location']),
      origin: place(json['origin']),
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'gender': gender,
    'image': image,
    'location': {'name': location},
    'origin': {'name': origin},
  };
}

class PersonPageModel extends PersonPage {
  const PersonPageModel({
    required super.persons,
    required super.nextPage,
    super.isCached,
  });
  factory PersonPageModel.fromJson(
    Map<String, dynamic> json, {
    bool cached = false,
  }) {
    final info = json['info'] as Map<String, dynamic>;
    final next = info['next'] as String?;
    return PersonPageModel(
      persons: List.unmodifiable(
        (json['results'] as List).map(
          (e) => PersonModel.fromJson(e as Map<String, dynamic>),
        ),
      ),
      nextPage: next == null
          ? null
          : int.parse(Uri.parse(next).queryParameters['page']!),
      isCached: cached,
    );
  }
  Map<String, dynamic> toJson() => {
    'info': {'next': nextPage == null ? null : '?page=$nextPage'},
    'results': persons.map((p) => (p as PersonModel).toJson()).toList(),
  };
}
