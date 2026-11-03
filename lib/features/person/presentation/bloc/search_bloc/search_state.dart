import 'package:equatable/equatable.dart';

import '../../../domain/entities/person_entity.dart';

enum SearchStatus { initial, loading, loaded, empty, error }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.persons = const [],
    this.nextPage,
    this.loadingMore = false,
    this.error,
  });
  final SearchStatus status;
  final String query;
  final List<PersonEntity> persons;
  final int? nextPage;
  final bool loadingMore;
  final String? error;
  @override
  List<Object?> get props => [
    status,
    query,
    persons,
    nextPage,
    loadingMore,
    error,
  ];
}
