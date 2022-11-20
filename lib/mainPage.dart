import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zero_tour/main/favoritePage.dart';
import 'package:zero_tour/main/mapPage.dart';
import 'package:zero_tour/main/settingPage.dart';

class MainPage extends StatefulWidget {
  // const MainPage({Key? key}) : super(key: key);
  final Future<Database> database;
  MainPage(this.database);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String _databaseURL = 'https://zerotour-3c3d2-default-rtdb.firebaseio.com/';
  String? id;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database!.reference();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    id = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: [
          MapPage(
            databaseReference: reference,
            db: widget.database,
            id: id,
          ),
          FavoritePage(
            databaseReference: reference,
            db: widget.database,
            id: id,
          ),
          SettingPage()
        ],
      ),
      bottomNavigationBar: TabBar(
        tabs: const [
          Tab(
            icon: Icon(Icons.map),
          ),
          Tab(
            icon: Icon(Icons.star),
          ),
          Tab(
            icon: Icon(Icons.settings),
          ),
        ],
        labelColor: Colors.amber,
        indicatorColor: Colors.deepOrangeAccent,
        controller: controller,
      ),
    );
  }
}
