import 'package:time_tracker/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:time_tracker/PageIntervals.dart';
import 'package:time_tracker/requests.dart';

class PageActivities extends StatefulWidget {
  final int id;
  @override
  _PageActivitiesState createState() => _PageActivitiesState();
  PageActivities(this.id);
}

class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late Future<Tree> futureTree;

  @override
  void initState() {
    super.initState();
    id = widget.id; // of PageActivities
    futureTree = getTree(id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.root.name),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {} // TODO go home page = root
                    ),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {} // TODO search by tag
                    ),
                //TODO other actions
              ],
            ),
            body: ListView.separated(
              // it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.root.children.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildRow(snapshot.data!.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                onPressed: () => {}
                //TODO ADD task or project
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

  void _navigateDownActivities(int childId) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId),
    ));
  }

  void _navigateDownIntervals(int childId) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    ));
  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration =
        Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list removes the microseconds part
    if (activity is Project) {
      return ListTile(
        trailing: Text('$strDuration'),
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'Project:   ',
              style: TextStyle(color: Colors.teal[300], fontSize: 23.0),
            ),
            TextSpan(
              text: '${activity.name}',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ]),
        ),
        onTap: () => _navigateDownActivities(activity.id),
      );
    } else if (activity is Task) {
      Task task = activity as Task;
      // at the moment is the same, maybe changes in the future
      Widget trailing;
      trailing = Text('$strDuration');
      return ListTile(
        //title: Text('Task: ${activity.name}', style: TextStyle(fontSize: 50.0)),
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'Task:   ',
              style: TextStyle(color: Colors.teal[300], fontSize: 23.0),
            ),
            TextSpan(
              text: '${activity.name}',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ]),
        ),

        trailing: trailing,
        onTap: () => _navigateDownIntervals(activity.id),
        onLongPress: () {}, // TODO start/stop counting the time for tis task
      );
    } else {
      throw (Exception("Activity that is neither a Task or a Project"));
      // this solves the problem of return Widget is not nullable because an
      // Exception is also a Widget?
    }
  }
}
