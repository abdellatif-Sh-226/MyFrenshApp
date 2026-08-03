import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../models/question_model.dart';

class JsonLoaderService {
  Future<List<Question>> loadUnitQuestions(int unitNumber) async {
    final path = AppConstants.unitFilePath(unitNumber);
    final jsonString = await rootBundle.loadString(path);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
  }
}
