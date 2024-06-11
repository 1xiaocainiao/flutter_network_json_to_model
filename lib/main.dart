import 'dart:convert';

import 'package:ai_app/tools/Webservice/request_result_container.dart';
import 'package:ai_app/tools/cache_helper.dart';
import 'package:flutter/material.dart';

class QueryData {
  final String title;
  final String description;

  QueryData({required this.title, required this.description});

  // 这里使用工厂方法fromJson _生成的代码将处理 JSON 的解码
  factory QueryData.fromJson(Map<String, dynamic> json) =>
      _$QueryDataFromJson(json);

  // toJson _生成的代码将处理对象到 JSON 的编码
  Map<String, dynamic> toJson() => _$QueryDataToJson(this);
}

QueryData _$QueryDataFromJson(Map<String, dynamic> json) => QueryData(
      title: json['title'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$QueryDataToJson(QueryData instance) => <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
    };

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final app = MyApp();
  app.initHelpers();
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void initHelpers() async {
    await CacheHelper.shared();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(CacheHelper.getInt("key"));
  }

  void _incrementCounter() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;

      if (_counter == 1) {
        CacheHelper.setInt("key", _counter);
        print("保存成功");
      }
    });

    final jsonString = '''
        {
          "code": "200",
          "message": "请求成功",
          "data": [
            {
            "title": "示例标题1",
            "description": "示例描述"
          },
          {
            "title": "示例标题2",
            "description": "示例描述"
          }
          ]
        }
      ''';
    //   var value = jsonDecode(jsonString);
    //   print("返回数据 $value");

    //   final container = RequestResultListContainer<QueryData>(value, QueryData.fromJson);
    //   print(container.value![1].title);

    //  final jsonString = '''
    //     {
    //       "code": "200",
    //       "message": "请求成功",
    //       "data": {
    //         "title": "示例标题1",
    //         "description": "示例描述"
    //       }
    //     }
    //   ''';
    var value = jsonDecode(jsonString);
    print("返回数据 $value");

    // final container = RequestResultContainer<QueryData>(value, QueryData.fromJson);
    // print(container.value!.title);

    // final container = RequestResultContainer<QueryData>(value, RequestReusltType.model, QueryData.fromJson);
    // print(container.value!.title);

    final container = RequestResultContainer<QueryData>(
        value, RequestReusltType.array,
        deserializable: QueryData.fromJson);
    print(container.values![0].title);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
