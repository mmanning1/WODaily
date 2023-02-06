import 'package:flutter/material.dart';

class Task {
  final String title;
  final int duration;
  final MaterialColor color;

  Task(this.title, this.duration, this.color);

  String durationToString() {
    final Duration d = Duration(seconds: duration);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
