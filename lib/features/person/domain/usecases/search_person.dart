import '../../../../core/usecases/usecase.dart';
import '../entities/person_entity.dart';
import '../repositories/person_repository.dart';

class SearchParams {
  const SearchParams(this.query, {this.page = 1});
  final String query;
  final int page;
}

class SearchPerson implements UseCase<PersonPage, SearchParams> {
  SearchPerson(this.repository);
  final PersonRepository repository;
  @override
  Future<PersonPage> call(SearchParams params) =>
      repository.searchPerson(params.query, params.page);
}
