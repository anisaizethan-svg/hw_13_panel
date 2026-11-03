import '../../../../core/usecases/usecase.dart';
import '../entities/person_entity.dart';
import '../repositories/person_repository.dart';

class GetAllPersons implements UseCase<PersonPage, int> {
  GetAllPersons(this.repository);
  final PersonRepository repository;
  @override
  Future<PersonPage> call(int params) => repository.getAllPersons(params);
}
