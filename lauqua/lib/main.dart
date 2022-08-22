
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// async dùng để khai báo một hàm bất đồng bộ,
// các hàm bất đồng bộ sẽ luôn trả về một giá trị
// việc sử dụng async chỉ đơn giản là ngụ ý rằng một lời hứa sẽ trả lại
// và nếu một lời hứa không được trả lại thì JS sẽ tự động kết thúc nó
void main() async {
  // đây là hàm nội bộ nên phải gọi setPreferredOrientations()
  // trước khi gọi runApp() nên ta dùng:
  WidgetsFlutterBinding.ensureInitialized();
  // await sử dụng để chờ một promise, chỉ được sử dụng bên trong 1 khối async(hàm không đồng bộ)
  // từ khóa await làm cho JS đợi cho đến khi promise trả về kết quả

  // thiết lập các hướng ưu tiên, sau khi nó hoàn thành thì ta chạy ứng dụng của mình
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
    // xóa nhãn debug trên màn hình ứng dụng
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
  List<Task> tasks = [
    Task(content: 'Write small apps', status: false),
    Task(content: 'Make todo list', status: true),
    Task(content: 'Commit changes and push to Github', status: false),
    Task(content: 'Blog writing', status: false),
    Task(content: 'Watch movie', status: false),
    Task(content: 'Credit registration', status: false),
    Task(content: 'Check CTMS', status: true),
    Task(content: 'Buy food', status: false),
    Task(content: 'Update calendar', status: true),
  ];
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
    // js map
    final List<int> incompleteTaskIndexes = tasks
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
                if (newIndex < allTaskIndexes.length) {
                  final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                  final task = tasks.removeAt(oldIndex);
                  tasks.insert(index, task);
                }
              }),
              itemBuilder: (context, index) {
                // final task = tasks[index];
                return buildTask(allTaskIndexes[index]);
              },
            ),
            ReorderableListView.builder(
              itemCount: incompleteTaskIndexes.length,
              onReorder: (oldIndex, newIndex) => setState(() {
                if (newIndex < incompleteTaskIndexes.length) {
                  oldIndex = incompleteTaskIndexes[oldIndex];
                  newIndex = incompleteTaskIndexes[newIndex];
                  final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                  final task = tasks.removeAt(oldIndex);
                  tasks.insert(index, task);
                }
              }),
              itemBuilder: (context, index) {
                // final task = CompleteTasks[index];
                return buildTask(incompleteTaskIndexes[index]);
              },
            ),
            ReorderableListView.builder(
              itemCount: completeTasksIndexes.length,
              onReorder: (oldIndex, newIndex) => setState(() {
                if (newIndex < completeTasksIndexes.length) {
                  oldIndex = completeTasksIndexes[oldIndex];
                  newIndex = completeTasksIndexes[newIndex];
                  final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                  final task = tasks.removeAt(oldIndex);
                  tasks.insert(index, task);
                }
              }),
              itemBuilder: (context, index) {
                // final task = IncompleteTasks[index];
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
    //final task = tasks[index];
    int taskIndex = tasks.indexOf(tasks[index]);

    return ListTile(
      key: ValueKey(index),
      contentPadding: const EdgeInsets.only(left: 10, right: 50),
      //title: Text(tasks.content),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: tasks[index].status,
            checkColor: Colors.white,
            activeColor: Colors.grey,
            onChanged: (value) {
              setState(() {
                tasks[index].status = !tasks[index].status;
                //true
                if (tasks[index].status) {
                  tasks.add(tasks.removeAt(index));
                } else {
                  //day len vi tri 0
                  tasks.insert(0, tasks.removeAt(index));
                }
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_upward,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                if (taskIndex > 0) {
                  var temp = tasks[taskIndex];
                  tasks[taskIndex] = tasks[taskIndex - 1];
                  tasks[taskIndex - 1] = temp;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_downward,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                if (taskIndex < tasks.length - 1) {
                  var temp = tasks[taskIndex];
                  tasks[taskIndex] = tasks[taskIndex + 1];
                  tasks[taskIndex + 1] = temp;
                }
              });
            },
          ),
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
                          initialValue: tasks[index].content,
                          onFieldSubmitted: (_) =>
                              Navigator.of(context).pop(),
                          onChanged: (content) {
                            setState(() => tasks[index].content = content);
                          }),
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
      // trim() cắt các khoảng trắng(dấu cách, kí tự xuống dòng, dấu tab) ở 2 đầu của xâu
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


