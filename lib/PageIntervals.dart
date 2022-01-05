import 'dart:async';

import 'package:codelab_timetraker/page_activities.dart';
import 'package:flutter/material.dart';
import 'package:codelab_timetraker/tree.dart' as Tree hide getTree;
import 'package:codelab_timetraker/requests.dart';
import 'dart:async';
class PageIntervals extends StatefulWidget {
  final int id; // final because StatefulWidget is immutable

  @override
  _PageIntervalsState createState() => _PageIntervalsState();
  PageIntervals(this.id);
}

class _PageIntervalsState extends State<PageIntervals> {
  late int id;
  late bool active = true;
  late Future<Tree.Tree> futureTree;
  late Timer _timer;
  static const int periodeRefresh = 1;
  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }
  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
  }
  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<Tree.Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          if (snapshot.data!.root is Tree.Task) {
            Tree.Task task = snapshot.data!.root as Tree.Task;
            active = task.active;
          }
          int numChildren = snapshot.data!.root.children.length;
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.root.name),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.home),
                    onPressed: () {
                      while(Navigator.of(context).canPop()) {
                        print("pop");
                        Navigator.of(context).pop();
                      }
                      /* this works also:
    Navigator.popUntil(context, ModalRoute.withName('/'));
  */
                      PageActivities(0);
                    }),
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: numChildren,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(snapshot.data!.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
            ),
            floatingActionButton: FloatingActionButton(
              child: active ? Icon(Icons.pause) : Icon(Icons.play_arrow),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              onPressed: () => setState(() {
                if (active) {
                  start(snapshot.data!.root.id);
                  Tree.Task task = snapshot.data!.root as Tree.Task;
                  task.active = false;
                  active = false;
                } else {
                  stop(snapshot.data!.root.id);
                  Tree.Task task = snapshot.data!.root as Tree.Task;
                  task.active = true;
                  active = true;
                }
              }),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Tree.Interval interval, int index) {
    String strDuration =
        Duration(seconds: interval.duration).toString().split('.').first;
    String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = interval.finalDate.toString().split('.')[0];
    return ListTile(
      title: Text('from ${strInitialDate} to ${strFinalDate}'),
      trailing: Text('$strDuration'),
    );
  }
}
