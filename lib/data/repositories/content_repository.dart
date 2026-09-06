import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/unit.dart';

/// Loads course content (units → lessons → questions) from the bundled seed
/// JSON. Cached after the first read.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  static const String _assetPath = 'assets/data/units.json';

  List<Unit>? _cache;

  Future<List<Unit>> loadUnits() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw) as List<dynamic>;
    _cache = decoded
        .map((e) => Unit.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
