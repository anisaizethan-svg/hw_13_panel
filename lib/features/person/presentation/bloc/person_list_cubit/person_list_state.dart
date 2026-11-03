import 'package:equatable/equatable.dart';

import '../../../domain/entities/person_entity.dart';

enum PersonListStatus { initial, loading, loaded, error }

class PersonListState extends Equatable {
  const PersonListState({
    this.status = PersonListStatus.initial,
    this.persons = const [],
    this.nextPage = 1,
    this.loadingMore = false,
    this.error,
    this.isCached = false,
  });
  final PersonListStatus status;
  final List<PersonEntity> persons;
  final int? nextPage;
  final bool loadingMore, isCached;
  final String? error;
  @override
  List<Object?> get props => [
    status,
    persons,
    nextPage,
    loadingMore,
    error,
    isCached,
  ];
}
