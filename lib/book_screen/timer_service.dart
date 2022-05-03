import 'package:flutter/material.dart';
import 'dart:async';
class TimerService extends ChangeNotifier {
  Timer? _timer;

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;
  bool finished = false;
  late DateTime _startTime;

  void _onTick(Timer timer) {
    _currentDuration = DateTime.now().difference(_startTime);

    // notify all listening widgets
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _startTime = DateTime.now();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _currentDuration = DateTime.now().difference(_startTime);
    finished = true;
    notifyListeners();
  }
}
