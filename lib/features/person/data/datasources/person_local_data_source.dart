import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/person_model.dart';

abstract class PersonLocalDataSource {
  Future<PersonPageModel> read(int page);
  Future<void> cache(int page, PersonPageModel data);
}

class PersonLocalDataSourceImpl implements PersonLocalDataSource {
  PersonLocalDataSourceImpl(this.preferences);
  final SharedPreferences preferences;
  String key(int page) => 'characters_v1_page_$page';
  @override
  Future<PersonPageModel> read(int page) async {
    try {
      final raw = preferences.getString(key(page));
      if (raw == null) {
        throw const CacheException();
      }
      return PersonPageModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
        cached: true,
      );
    } catch (_) {
      throw const CacheException();
    }
  }

  @override
  Future<void> cache(int page, PersonPageModel data) async {
    if (!await preferences.setString(key(page), jsonEncode(data.toJson()))) {
      throw const CacheException();
    }
  }
}
