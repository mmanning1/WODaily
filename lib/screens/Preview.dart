import 'package:WODaily/utils/Task.dart';
import 'package:flutter/material.dart';

class Preview extends StatelessWidget {
  final List<Task> tasks;

  const Preview({Key key, this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        separatorBuilder: (context, i) => SizedBox(
          height: 10,
        ),
        itemBuilder: (context, i) {
          return Material(
            elevation: 2,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: tasks[i].color[50],
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tasks[i].title, style: TextStyle(color: tasks[i].color[800], fontSize: 20)),
                  Text(tasks[i].durationToString(), style: TextStyle(color: tasks[i].color[800], fontSize: 15))
                ],
              ),
            ),
          );
        },
        itemCount: tasks.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
      ),
    );
  }
}
