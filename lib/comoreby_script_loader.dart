import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ComorebyScriptLoader {
  static const String _scriptPath = 'assets/js/comoreby.js';
  static String? _cachedReleaseScript;

  static Future<String> loadForInjection() async {
    if (kReleaseMode) {
      _cachedReleaseScript ??= await rootBundle.loadString(_scriptPath);
      return _cachedReleaseScript!;
    }

    return rootBundle.loadString(_scriptPath, cache: false);
  }
}
