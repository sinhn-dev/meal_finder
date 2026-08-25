import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';

class Debouncer {
  Debouncer({this.duration = AppConstants.searchDebounce});

  final Duration duration;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
