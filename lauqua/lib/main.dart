// ignore: avoid_web_libraries_in_flutter

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'TodoList';

  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  List<Task> displayedTasks = [];
  String currentStatus = 'all';
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final allTaskIndexes = tasks.map((e) => tasks.indexOf(e)).toList();
    final incompleteTaskIndexes = tasks
        .where((element) => !element.status)
        .map((e) => tasks.indexOf(e))
        .toList();
    final completeTasksIndexes = tasks
        .where((element) => element.status)
        .map((e) => tasks.indexOf(e))
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ItemSearch(tasks),
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
          title: const Text(MyApp.title),
          centerTitle: true,
          bottom: const TabBar(tabs: [
            Tab(text: 'All', icon: Icon(Icons.all_inbox_outlined)),
            Tab(text: 'Incomplete', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
          ]),
        ),
        body: TabBarView(
          children: [
            ReorderableListView.builder(
              itemCount: allTaskIndexes.length,
              onReorder: (oldIndex, newIndex) => setState(() {
                final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                final task = tasks.removeAt(oldIndex);
                tasks.insert(index, task);
              }),
              itemBuilder: (context, index) {
                //final task = tasks[index];
                return buildTask(allTaskIndexes[index]);
              },
            ),
            ReorderableListView.builder(
              itemCount: incompleteTaskIndexes.length,
              onReorder: (oldIndex, newIndex) => setState(() {
                oldIndex = incompleteTaskIndexes[oldIndex];
                newIndex = incompleteTaskIndexes[newIndex];
                final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                final task = tasks.removeAt(oldIndex);
                tasks.insert(index, task);
              }),
              itemBuilder: (context, index) {
                //final task = CompleteTasks[index];
                return buildTask(incompleteTaskIndexes[index]);
              },
            ),
            ReorderableListView.builder(
              itemCount: completeTasksIndexes.length,
              onReorder: (oldIndex, newIndex) => setState(() {
                oldIndex = completeTasksIndexes[oldIndex];
                newIndex = completeTasksIndexes[newIndex];
                final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                final task = tasks.removeAt(oldIndex);
                tasks.insert(index, task);
              }),
              itemBuilder: (context, index) {
                //final task = IncompleteTasks[index];
                return buildTask(completeTasksIndexes[index]);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            String newTask = '';
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    title: const Text('New Todo'),
                    content: TextField(
                      onChanged: (String value) {
                        newTask = value;
                      },
                      decoration: const InputDecoration(
                          hintText: 'Enter something to do...',
                          contentPadding: EdgeInsets.all(16.0)),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      FlatButton(
                        onPressed: () {
                          if (newTask.isNotEmpty) {
                            setState(() {
                              Task task =
                                  Task(status: isChecked, content: newTask);
                              tasks.add(task);
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                });
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Widget _generateButton({required String value}) {
  //   // ignore: duplicate_ignore
  //   return Container(
  //     margin: const EdgeInsets.all(10),
  //     child: ElevatedButton(
  //       onPressed: () {
  //         setState(() {
  //           currentStatus = value;
  //         });
  //       },
  //       child: Text('$value'),
  //     ),
  //   );
  // }

  Widget buildTask(int index) {
    final task = tasks[index];
    return ListTile(
      key: ValueKey(index),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //title: Text(tasks.content),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: tasks[index].status,
                checkColor: Colors.white,
                activeColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    tasks[index].status = !tasks[index].status;
                  });
                },
              ),
              Text(
                tasks[index].content.toString(),
                style: TextStyle(
                  decoration: tasks[index].status
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          title: const Text('Edit Item'),
                          content: TextFormField(
                            initialValue: task.content,
                            onFieldSubmitted: (_) =>
                                Navigator.of(context).pop(),
                            onChanged: (content) =>
                                setState(() => task.content = content),
                          ),
                        );
                      });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        title: const Text('Please Confirm'),
                        content: const Text(
                          'Are you sure to remove this item?',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                tasks.removeAt(index);
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemSearch extends SearchDelegate<Task> {
  final List<Task> tasks;

  List<Task> _filter = [];

  ItemSearch(this.tasks);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
    );
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemCount: _filter.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text(_filter[index].content),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filter = tasks.where((task) {
      return task.content.toLowerCase().contains(query.trim().toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: _filter.length,
      itemBuilder: (_, index) {
        return ListTile(
          title: Text(_filter[index].content),
        );
      },
    );
  }
}

class Task {
  String content;
  bool status;
  Task({required this.content, required this.status});
}
