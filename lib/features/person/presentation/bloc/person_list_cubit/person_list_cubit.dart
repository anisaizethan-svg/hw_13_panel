import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/usecases/get_all_persons.dart';
import 'person_list_state.dart';

class PersonListCubit extends Cubit<PersonListState> {
  PersonListCubit(this.getAllPersons) : super(const PersonListState());
  final GetAllPersons getAllPersons;
  Future<void> loadNext() async {
    if (state.status == PersonListStatus.loading ||
        state.loadingMore ||
        state.nextPage == null) {
      return;
    }
    final previous = state;
    emit(
      PersonListState(
        status: previous.persons.isEmpty
            ? PersonListStatus.loading
            : PersonListStatus.loaded,
        persons: previous.persons,
        nextPage: previous.nextPage,
        loadingMore: previous.persons.isNotEmpty,
        isCached: previous.isCached,
      ),
    );
    try {
      final page = await getAllPersons(previous.nextPage!);
      if (isClosed) {
        return;
      }
      final ids = previous.persons.map((p) => p.id).toSet();
      emit(
        PersonListState(
          status: PersonListStatus.loaded,
          persons: List.unmodifiable([
            ...previous.persons,
            ...page.persons.where((p) => ids.add(p.id)),
          ]),
          nextPage: page.nextPage,
          isCached: previous.isCached || page.isCached,
        ),
      );
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(
        PersonListState(
          status: previous.persons.isEmpty
              ? PersonListStatus.error
              : PersonListStatus.loaded,
          persons: previous.persons,
          nextPage: previous.nextPage,
          error: e is Failure
              ? e.message
              : 'Unable to load characters. Please retry.',
          isCached: previous.isCached,
        ),
      );
    }
  }
}
