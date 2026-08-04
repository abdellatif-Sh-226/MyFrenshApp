import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../models/question_model.dart';
import 'api_service.dart';

Future<List<Question>> loadLocalUnitQuestions(int unitNumber) async {
  final path = AppConstants.unitFilePath(unitNumber);
  final jsonString = await rootBundle.loadString(path);
  final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
  return jsonList.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
}

class JsonLoaderService {
  final ApiService? _api;

  JsonLoaderService([this._api]);

  Future<List<Question>> loadUnitQuestions(int unitNumber) async {
    final api = _api;
    if (api != null && api.isAuthenticated) {
      try {
        return await api.fetchUnitQuestions(unitNumber);
      } catch (_) {
        // Fall back to the bundled local JSON when offline or the server fails.
      }
    }
    return loadLocalUnitQuestions(unitNumber);
  }
}
