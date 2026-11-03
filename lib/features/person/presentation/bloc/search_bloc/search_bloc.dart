import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/usecases/search_person.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this.searchPerson, {
    this.debounce = const Duration(milliseconds: 350),
  }) : super(const SearchState()) {
    on<SearchQueryChanged>(_query);
    on<SearchNextPage>(_next);
  }
  final SearchPerson searchPerson;
  final Duration debounce;
  int _generation = 0;
  Future<void> _query(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final generation = ++_generation;
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }
    emit(SearchState(status: SearchStatus.loading, query: query));
    await Future<void>.delayed(debounce);
    if (generation != _generation || emit.isDone) {
      return;
    }
    await _fetch(query, 1, generation, emit);
  }

  Future<void> _next(SearchNextPage event, Emitter<SearchState> emit) async {
    if (state.status != SearchStatus.loaded ||
        state.loadingMore ||
        state.nextPage == null) {
      return;
    }
    final s = state;
    emit(
      SearchState(
        status: s.status,
        query: s.query,
        persons: s.persons,
        nextPage: s.nextPage,
        loadingMore: true,
      ),
    );
    await _fetch(s.query, s.nextPage!, _generation, emit, append: true);
  }

  Future<void> _fetch(
    String query,
    int page,
    int generation,
    Emitter<SearchState> emit, {
    bool append = false,
  }) async {
    final old = state.persons;
    try {
      final result = await searchPerson(SearchParams(query, page: page));
      if (generation != _generation || emit.isDone) {
        return;
      }
      final ids = old.map((p) => p.id).toSet();
      final persons = append
          ? [...old, ...result.persons.where((p) => ids.add(p.id))]
          : result.persons;
      emit(
        SearchState(
          status: persons.isEmpty ? SearchStatus.empty : SearchStatus.loaded,
          query: query,
          persons: List.unmodifiable(persons),
          nextPage: result.nextPage,
        ),
      );
    } catch (e) {
      if (generation != _generation || emit.isDone) {
        return;
      }
      emit(
        SearchState(
          status: append ? SearchStatus.loaded : SearchStatus.error,
          query: query,
          persons: append ? old : const [],
          nextPage: append ? page : null,
          error: e is Failure ? e.message : 'Unable to search. Please retry.',
        ),
      );
    }
  }
}
