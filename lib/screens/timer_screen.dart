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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
                      final data = value[index];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${index + 1} - ${data.displayTime}'),
                          ),
                        ],
                      );
                    });
                }
              ),
            ),
            StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snapshot) {
              final value = snapshot.data;
              final displayTime = StopWatchTimer.getDisplayTime(value, hours: _isHours);
              return Text(displayTime, style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
                fontSize: 52,
              ),);
            }),
            const SizedBox(height: 30,),
            buildButtons(),
          ],
        ),
      ),
    );
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
        FloatingActionButton(
          backgroundColor: Colors.blue.shade900,
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