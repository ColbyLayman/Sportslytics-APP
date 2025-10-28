import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';

class NCData {
  final String state;
  final List<School> schools;
  NCData({required this.state, required this.schools});
}

class NCLoader {
  static Future<NCData> load() async {
    final raw = await rootBundle.loadString('assets/data/nc_d1.json');
    final j = json.decode(raw);
    final schools =
        (j['schools'] as List).map((s) => School.fromJson(s)).toList();
    return NCData(state: j['state'], schools: schools);
  }
}
