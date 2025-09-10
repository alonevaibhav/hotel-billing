// 2. Service to load local JSON file
import 'dart:developer' as development;

import 'package:flutter/services.dart';
import 'dart:convert';
import '../../app/data/models/table_model.dart';

class LocalJsonService {


  static Future<TablesResponse> loadTablesFromJson() async {
    try {
      // Load JSON file from assets
      String jsonString = await rootBundle.loadString('lib/demo/Json/tables.json');

      // Parse JSON
      Map<String, dynamic> jsonData = json.decode(jsonString);

      development.log('Loaded JSON Data: $jsonData', name: 'LocalJsonService');

      // Convert to model
      return TablesResponse.fromJson(jsonData);
    } catch (e) {
      throw Exception('Error loading local JSON: $e');
    }
  }

}
