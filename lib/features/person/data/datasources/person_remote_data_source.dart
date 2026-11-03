import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/person_model.dart';

abstract class PersonRemoteDataSource {
  Future<PersonPageModel> fetch(int page, {String query = ''});
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  PersonRemoteDataSourceImpl(this.client);
  final http.Client client;
  @override
  Future<PersonPageModel> fetch(int page, {String query = ''}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/character/').replace(
        queryParameters: {'page': '$page', if (query.isNotEmpty) 'name': query},
      );
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 404 && query.isNotEmpty) {
        return const PersonPageModel(persons: [], nextPage: null);
      }
      if (response.statusCode == 429) {
        throw const ServerException(
          'Too many requests. Please wait a moment and retry.',
        );
      }
      if (response.statusCode != 200) {
        throw ServerException(
          'Server error (${response.statusCode}). Please retry.',
        );
      }
      return PersonPageModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } on ServerException {
      rethrow;
    } on TimeoutException {
      throw const ServerException('The request timed out. Please retry.');
    } on http.ClientException {
      throw const ServerException(
        'Cannot reach the server. Check your connection.',
      );
    } catch (_) {
      throw const ServerException(
        'The server returned invalid character data.',
      );
    }
  }
}
