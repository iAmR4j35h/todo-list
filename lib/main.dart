import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/component/TaskWidget.dart';
import 'package:todo_app/db/Task.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('taskBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '#todo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TextEditingController addTaskController = TextEditingController();

  TabController _tabController;
  Box<Task> task;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    task = Hive.box<Task>("taskBox");
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
            child: Text(
          widget.title,
          style: TextStyle(color: Color(0xFF333333), fontSize: 30),
        )),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              child: Text("All", style: TextStyle(color: Color(0xFF333333))),
            ),
            Tab(
              child: Text("Active", style: TextStyle(color: Color(0xFF333333))),
            ),
            Tab(
              child: Text("Completed", style: TextStyle(color: Color(0xFF333333))),
            ),
          ],
        ),
      ),

      body: Column(
        children: <Widget>[
          if (_tabController.index != 2)
            Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: addTaskController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "add details",
                          hintStyle: TextStyle(color: Color(0xff828282))),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  FlatButton(
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        final atask = Task(addTaskController.text, true);
                        task.add(atask);
                        addTaskController.text = "";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.blue,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                  )
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  ValueListenableBuilder(
                    valueListenable: Hive.box<Task>("taskBox").listenable(),
                    builder: (context, Box<Task> value, child) => Container(
                        child: ListView.builder(
                      itemBuilder: (context, index) => TaskWidget(
                        data: value.getAt(index),
                        onCheckChange: (c) {
                          final item = value.getAt(index);
                          item.isActive = !c;
                          item.save();
                        },
                      ),
                      itemCount: value.length,
                    )),
                  ),
                  ValueListenableBuilder(
                      valueListenable: Hive.box<Task>("taskBox").listenable(),
                      builder: (context, Box<Task> value, child) {
                        var activeList = value.values.toList();
                        activeList.removeWhere((v) => !v.isActive);
                        return Container(
                            child: ListView.builder(
                          itemBuilder: (context, index) => TaskWidget(
                            data: activeList[index],
                            onCheckChange: (c) {
                              final item = activeList[index];
                              item.isActive = !c;
                              item.save();
                            },
                          ),
                          itemCount: activeList.length,
                        ));
                      }),
                  ValueListenableBuilder(
                      valueListenable: Hive.box<Task>("taskBox").listenable(),
                      builder: (context, Box<Task> value, child) {
                        var completeList = value.values.toList();
                        completeList.removeWhere((v) => v.isActive);
                        return Column(
                          children: <Widget>[
                            ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (context, index) => TaskWidget(
                                data: completeList[index],
                                onCheckChange: (c) async {
                                  final item = completeList[index];
                                  item.isActive = !c;
                                  item.save();
                                },
                                isDelete: true,
                                onDelete: () async {
                                  final item = completeList[index];
                                  item.delete();
                                },
                              ),
                              itemCount: completeList.length,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if (completeList.isNotEmpty)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: FlatButton(
                                  color: Color(0xffEB5757),
                                  onPressed: () {
                                    setState(() {
                                      completeList.forEach((element) {
                                        element.delete();
                                      });
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "delete all",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                          ],
                        );
                      }),
                ],
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
              ),
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
