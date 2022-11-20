import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/tour.dart';

class FavoritePage extends StatefulWidget {
  // const FavoritePage({Key? key}) : super(key: key);
  final DatabaseReference? databaseReference;
  final Future<Database>? db;
  final String? id;

  FavoritePage({this.databaseReference, this.db, this.id});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Future<List<TourData>>? _tourList;

  @override
  void initState() {
    super.initState();
    _tourList = getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<List<TourData>>? getTodos() async {
    final Database database = await widget.db!;
    final List<Map<String, dynamic>> maps = await database.query('place');

    return List.generate(maps.length, (i) {
      return TourData(
          title: maps[i]['title'].toString(),
          tel: maps[i]['tel'].toString(),
          address: maps[i]['address'].toString(),
          zipcode: maps[i]['zipcode'].toString(),
          mapy: maps[i]['mapy'].toString(),
          mapx: maps[i]['tel'].toString(),
          imagePath: maps[i]['imagePath'].toString());
    });
  }
}
