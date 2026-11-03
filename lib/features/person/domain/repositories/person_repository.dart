import '../entities/person_entity.dart';

abstract class PersonRepository {
  Future<PersonPage> getAllPersons(int page);
  Future<PersonPage> searchPerson(String query, int page);
}
