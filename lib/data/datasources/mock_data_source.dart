import 'dart:convert';

import 'package:flutter/services.dart';

class MockDataSource {
  static const String _assetPath =
      'assets/mock_data/TaskFlow-MockData.json';

  Map<String, dynamic>? _data;

  Future<void> _loadData() async {
    if (_data != null) return;

    final jsonString = await rootBundle.loadString(_assetPath);

    _data = jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getList(String key) async {
    await _loadData();

    final value = _data![key];

    if (value is! List) {
      throw Exception('Mock collection "$key" not found');
    }

    return value
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> getObject(String key) async {
    await _loadData();

    final value = _data![key];

    if (value is! Map) {
      throw Exception('Mock object "$key" not found');
    }

    return Map<String, dynamic>.from(value);
  }
}