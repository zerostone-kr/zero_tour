import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';

import '../data/listData.dart';
import '../data/tour.dart';

class MapPage extends StatefulWidget {
  // const MapPage({Key? key}) : super(key: key);

  final DatabaseReference? databaseReference;
  final Future<Database>? db;
  final String? id;

  MapPage({this.databaseReference, this.db, this.id});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<DropdownMenuItem<Item>> list = List.empty(growable: true);
  List<DropdownMenuItem<Item>> sublist = List.empty(growable: true);
  List<TourData> tourData = List.empty(growable: true);
  ScrollController? _scrollController;

  String authKey =
      'mIZVonJIsYWKCcwjdMfSVt9WBrIV9qz2HMDFtRmxSN2hPFc6EfRu%2FrDThBX1seAOZW%2Be%2F33wRMIx5tnbahA9CA%3D%3D';

  Item? area;
  Item? kind;
  int page = 1;

  @override
  void initState() {
    super.initState();
    list = Area().seoulArea;
    sublist = Kind().kinds;

    area = list[0].value;
    kind = sublist[0].value;

    _scrollController = new ScrollController();
    _scrollController!.addListener(() {
      if (_scrollController!.offset >=
              _scrollController!.position.maxScrollExtent &&
          !_scrollController!.position.outOfRange) {
        page++;
        getAreaList(area: area!.value, contentTypeId: kind!.value, page: page);
      }
    });
  }

  void getAreaList(
      {required int area,
      required int contentTypeId,
      required int page}) async {
    var url =
        'ttps://apis.data.go.kr/B551011/KorService/areaBasedList?serviceKey=$authKey&numOfRows=10&pageNo=$page&MobileOS=ETC&MobileApp=AppTest&_type=json&listYN=Y&arrange=C&areaCode=1&sigunguCode=$area';
    if (contentTypeId != 0) {
      url = url + '&contentTypeId=$contentTypeId';
    }

    var response = await http.get(Uri.parse(url));
    String body = utf8.decode(response.bodyBytes);
    print(body);
    var json = jsonDecode(body);
    if (json['response']['header']['resultCode'] == "0000") {
      if (json['response']['body']['item'] == '') {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('마지막 데이터 입니다.'),
              );
            });
      } else {
        List jsonArray = json['response']['body']['items']['item'];
        for (var s in jsonArray) {
          setState(() {
            tourData.add(TourData.fromJson(s));
          });
        }
      }
    } else {
      print('error');
    }
  }

  ImageProvider getImage(String? imagePath) {
    if (imagePath != null) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage('repo/images/map_location.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색하기'),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  DropdownButton(
                    items: list,
                    onChanged: (value) {
                      Item selectedItem = value!;
                      setState(() {
                        area = selectedItem;
                      });
                    },
                    value: area,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton(
                      items: sublist,
                      onChanged: (value) {
                        Item selectItem = value!;
                        setState(() {
                          kind = selectItem;
                        });
                      }),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      page = 1;
                      tourData.clear();
                      getAreaList(
                          area: area!.value,
                          contentTypeId: kind!.value,
                          page: page);
                    },
                    child: Text(
                      '검색하기',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueAccent)),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
              Expanded(
                child: ListView.builder(itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      child: Row(
                        children: [
                          Hero(
                              tag: 'tourinfo$index',
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  width: 100.0,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image:
                                          getImage(tourData[index].imagePath),
                                    ),
                                  ))),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
