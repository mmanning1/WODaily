import 'dart:async';
import 'package:WODaily/screens/Preview.dart';
import 'package:WODaily/utils/Clock.dart';
import 'package:WODaily/utils/Task.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TabataScreen extends StatefulWidget{

  @override
  _TabataScreenState createState() => _TabataScreenState();
}

class _TabataScreenState extends State<TabataScreen> with TickerProviderStateMixin{
  AnimationController controller;
  List<Task> tasks = [];
  int current = 0;
  double rounds = 8;
  double work = 20;
  double rest = 10;


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    generateTasks();
    controller = AnimationController(
        vsync: this, duration: Duration(seconds: tasks[current].duration))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (current + 1 >= tasks.length) {
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                      content: Text('Workout Finished'),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        )
                      ]);
                });
            return;
          }
          current += 1;
          controller.duration = Duration(seconds: tasks[current].duration);
          controller.forward(from: 0.0);
          setState(() {});
        }
      });
    super.initState();
  }

  void generateTasks() {
    setState(() {
      // Defaults to 8 rounds with 20 seconds of work with 10 seconds rest
      tasks = [Task('Ready', rest.toInt(), Colors.cyan)];
      for (int i in List.generate(rounds.toInt(), (i) => i)) {
        tasks = [
          ...tasks,
          Task('Exercise', work.toInt(), Colors.blue),
          if (i < rounds.toInt() - 1)
            Task('Rest', rest.toInt(), Colors.green)
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabata'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Clock(
                size: Size(300, 300),
                task: tasks[current],
                controller: controller),
            Preview(tasks: tasks.skip(current).toList()),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.delete_sharp),
                  label: Text('Delete'),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Sure to delete?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text('Confirm'),
                              onPressed: () async {
                                //await widget.workout.remove();
                                Navigator.pop(context);
                                Navigator.pop(context, true);
                              },
                            )
                          ],
                        ));
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.settings),
                  label: Text('Set'),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            title: Text('Set Tabata times'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  Text('Work: '),
                                  Slider(
                                    value: work,
                                    min: 1,
                                    max: 100,
                                    divisions: 100,
                                    label: work.round().toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        work = value.roundToDouble();
                                      });
                                    },
                                  ),
                                  Text('Rest: '),
                                  Slider(
                                    value: rest,
                                    min: 1,
                                    max: 100,
                                    divisions: 100,
                                    label: rest.round().toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        rest = value.roundToDouble();
                                      });
                                    },
                                  ),
                                  Text('Rounds: '),
                                  Slider(
                                    value: rounds,
                                    min: 1,
                                    max: 25,
                                    divisions: 100,
                                    label: rounds.round().toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        rounds = value.roundToDouble();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text('Save'),
                                onPressed: () async {
                                  generateTasks();
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          );
                        }),
                    );
                  },
                ),
                AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      return TextButton.icon(
                          onPressed: () {
                            if (controller.isAnimating) {
                              controller.stop();
                            } else {
                              controller.forward();
                            }
                            setState(() {}); // sad but I have to do that :(
                          },
                          icon: Icon(controller.isAnimating
                              ? Icons.pause
                              : Icons.play_arrow),
                          label: Text(controller.isAnimating
                              ? 'Pause'
                              : 'Play'));
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

}