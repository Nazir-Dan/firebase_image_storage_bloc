import 'package:flutter/foundation.dart';

extension IfDebugging on String {
  String? get isDebugging => kDebugMode ? this : null;
}
