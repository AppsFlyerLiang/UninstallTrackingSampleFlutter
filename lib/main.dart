import 'package:flutter/material.dart';
import 'package:flutter_uninstall_sample/app_config.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initAppsFlyerSdk();
  AppConfig.initFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfig.statusData),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var status = Provider.of<StatusData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "AppsFlyer Status",
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            '${status.appsFlyerStatus}',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Text(
            'Firebase Status:',
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            '${status.firebaseStatus}',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      )
    );
  }
}
