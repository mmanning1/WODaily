import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {

  @override
  _TimerScreenState createState() => _TimerScreenState();

}

class _TimerScreenState extends State<TimerScreen>{
  static const countdownDuration = Duration(minutes:10 );
  Duration duration = Duration();
  Timer timer;

  bool isCountdown = false;

  @override
  void initState() {
    super.initState();
    //startTimer();
  }

  void reset(){
    if (isCountdown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = Duration());
    }
  }

  void startTimer ({bool resets = true}) {
    if (resets) {
      reset();
    }
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }

    setState(() => timer.cancel());
  }

  void addTime () {
    final addSeconds = isCountdown ? -1 : 1;

    if (mounted) {
      setState(() {
        final seconds = duration.inSeconds + addSeconds;

        if(seconds < 0) {
          timer.cancel();
          //todo maybe beep here?
        } else {
          duration = Duration(seconds: seconds);
        }
      });
    }
  }

  @override
  void dispose() {
    if (timer!=null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTime(),
            const SizedBox(height: 30,),
            buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = twoDigits(duration.inHours.remainder(60));

    /*
    return Text(
      '$minutes:$seconds',
      style: TextStyle(fontSize: 80),
    );
     */

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimeCard(time: hours, header: 'Hours'),
        const SizedBox(width: 5),
        buildTimeCard(time: minutes, header: 'Minutes'),
        const SizedBox(width: 5),
        buildTimeCard(time: seconds, header: 'Seconds'),
      ],
    );
  }

  Widget buildTimeCard({String time, String header}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(15)
          ),
          child: Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 72,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(header)
      ],
    );
  }

  Widget buildButtons() {
    final isRunning = timer == null ? false : timer.isActive;
    final isCompleted = duration.inSeconds == 0;

    return isRunning || !isCompleted ?
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.blue.shade900,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            ),
            child: Text(isRunning ? "Stop":"Resume",style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (isRunning) {
                stopTimer(resets: false);
              } else {
                startTimer(resets: false);
              }
            }
        ),
        const SizedBox(width: 10.0,),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.blue.shade900,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            ),
            child: Text("Cancel",style: TextStyle(color: Colors.white)),
            onPressed: () {
              stopTimer(resets: true);
            }
        ),
      ],
    ):
    ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.blue.shade900,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)
        ),
        child: Text("Start Timer",style: TextStyle(color: Colors.white)),
        onPressed: () {
          startTimer();
        }
    );
  }

}