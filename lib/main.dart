import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zero_tour/login.dart';
import 'package:zero_tour/signPage.dart';
import 'package:zero_tour/mainPage.dart';

// https://zerotour-3c3d2-default-rtdb.firebaseio.com/   firebase ID
// ca-app-pub-6628897297808372~2680385762   admob
// ca-app-pub-6628897297808372/3074550700   admon - 광고단위 (배너)

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Database> initDatabase() async {
    return openDatabase(join(await getDatabasesPath(), 'tour_database.db'),
        onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE place(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, tel TEXT, zipcode TEXT, address TEXTm mapx Number, mapy Number, imagePath TEXT)",
      );
    }, version: 1);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<Database> database = initDatabase();

    return MaterialApp(
      title: '제로의 한국여행 가이드',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/sign': (context) => SignPage(),
        '/main': (context) => MainPage(database),
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
