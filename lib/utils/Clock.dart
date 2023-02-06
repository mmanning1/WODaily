import 'package:WODaily/utils/Task.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class Clock extends StatelessWidget {
  final Size size;
  final Task task;
  final AnimationController controller;

  const Clock({Key key, this.size, this.controller, this.task})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Center(
        child: Column(children: [
          Container(
            height: size.height,
            width: size.width,
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                return Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                      width: size.width,
                      height: size.height,
                      child: CustomPaint(
                          painter: ClockPainter(
                              controller, Colors.black26, Colors.blue[800])),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildReminding(),
                        Text(
                          task.title,
                          style: TextStyle(
                              fontSize: 20, fontStyle: FontStyle.italic),
                        )
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget buildReminding() {
    var reminding = task.duration - (controller.value * task.duration);
    if(reminding.toStringAsFixed(1) == '3.5'){
      FlutterRingtonePlayer.play(fromAsset: 'assets/race-start-beeps.mp3');
    }
    /*if(reminding.toStringAsFixed(1) == '3.0'){
        FlutterRingtonePlayer.play(fromAsset: 'assets/beepShort.mp3');
    } else if(reminding.toStringAsFixed(1) == '2.0'){
      FlutterRingtonePlayer.play(fromAsset: 'assets/beepShort.mp3');
    } else if(reminding.toStringAsFixed(1) == '1.0'){
      FlutterRingtonePlayer.play(fromAsset: 'assets/beepShort.mp3');
    }
    if(reminding == task.duration && task.title != 'Ready'){
      FlutterRingtonePlayer.play(fromAsset: 'assets/beepLong.mp3');
    }*/
    return Text(
      reminding.toStringAsFixed(0),
      style: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w300,
          color: Color.lerp(Colors.black, Colors.red[600], controller.value)),
    );
  }

}

class ClockPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor, color;

  ClockPainter(this.animation, this.backgroundColor, this.color)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero),
        size.width / 2.0 - paint.strokeWidth / 2, paint);
    paint.color = color;
    double progress = (animation.value) * 2 * pi;
    var o = Offset.zero & size;
    canvas.drawArc(
        o.deflate(paint.strokeWidth / 2), pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
