import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TimerScreen extends StatefulWidget {

  @override
  _TimerScreenState createState() => _TimerScreenState();

}

class _TimerScreenState extends State<TimerScreen>{
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final _isHours = true;
  final _scrollController = ScrollController();
  bool isCountdown = false;

  @override
  void initState() {
    super.initState();
    //startTimer();
  }

  void resetTimer(){
    _stopWatchTimer.onResetTimer();
  }

  void startTimer () {
    _stopWatchTimer.onStartTimer();
  }

  void stopTimer() {
    _stopWatchTimer.onStopTimer();
  }

  void lapTime() {
    _stopWatchTimer.onAddLap();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    _scrollController.dispose();
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50,),
            buildTime(),
            const SizedBox(height: 50,),
            buildButtons(),
            const SizedBox(height: 50,),
            buildLaps(),
          ],
        ),
      ),
    );
  }

  Widget buildTime() {
    return StreamBuilder<int>(
      stream: _stopWatchTimer.rawTime,
      initialData: _stopWatchTimer.rawTime.value,
      builder: (context, snapshot) {
        final value = snapshot.data;
        final displayTime = StopWatchTimer.getDisplayTime(value, hours: _isHours);
        return Text(
          displayTime,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
            fontSize: 52,
            ),
          );
        }
      );
  }

  Widget buildLaps() {
    return Expanded(
      child: Container(
        color: Colors.grey[300],
        height: 120,
        margin: const EdgeInsets.all(8),
        child: StreamBuilder<List<StopWatchRecord>>(
          stream: _stopWatchTimer.records,
          initialData: _stopWatchTimer.records.value,
          builder: (context, snapshot) {
            final value = snapshot.data;
            if(value.isEmpty){
              return Container();
            }
            Future.delayed(const Duration(milliseconds: 100), () {
              _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            });
            return ListView.builder(
                itemCount: value.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  final diff = calcSplit(value, index);
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('#${index + 1} - ${diff}'),
                      ),
                    ],
                  );
                });
            }
        ),
      )
    );
  }

  String calcSplit(List<StopWatchRecord> value, int index){
    if(index==0){
      return StopWatchTimer.getDisplayTime(value[index].rawValue, hours: false);
    } else {
      int diff = value[index].rawValue - value[index-1].rawValue;
      return '${value[index].displayTime}' + '  (${StopWatchTimer.getDisplayTime(diff, hours: false)})';
    }

  }

  Widget buildButtons() {
    final isRunning = _stopWatchTimer.isRunning;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            ),
            child: Text("Lap",style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                lapTime();
              });
            }
        ),
        const SizedBox(width: 10.0,),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: Colors.blue.shade900,
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18)
            ),
          child: isRunning ? Icon(Icons.pause,color: Colors.white) : Icon(Icons.play_arrow,color: Colors.white),
          onPressed: () {
            setState(() {
              if (isRunning) {
                stopTimer();
              } else {
                startTimer();
              }
            });
          }
        ),
        const SizedBox(width: 10.0,),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            ),
            child: Text("Reset",style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                resetTimer();
              });
            }
        ),
      ],
    );
  }

}