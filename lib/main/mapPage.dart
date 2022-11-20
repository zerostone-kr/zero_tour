import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zero_tour/data/listData.dart';
import 'package:zero_tour/data/tour.dart';
import 'package:zero_tour/main/tourDetailPage.dart';

import '../API/apiCall.dart';
import '../API/httpClientApi.dart';

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
        'https://apis.data.go.kr/B551011/KorService/areaBasedList?serviceKey=$authKey&numOfRows=10&pageNo=$page&MobileOS=ETC&MobileApp=AppTest&_type=json&listYN=Y&arrange=C&areaCode=1&sigunguCode=$area';
    if (contentTypeId != 0) {
      url = url + '&contentTypeId=$contentTypeId';
    }

    print(url);

    // var response = await http.get(Uri.parse(url));
    // String body = utf8.decode(response.bodyBytes);

    String body = await getHttpClientGetApi(url);
    print(body);

    var json = jsonDecode(body);
    if (json['response']['header']['resultCode'] == "0000") {
      if (json['response']['body']['item'] == '') {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton<Item>(
                    items: list,
                    onChanged: (value) {
                      Item selectedItem = value!;
                      setState(() {
                        area = selectedItem;
                      });
                    },
                    value: area,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  DropdownButton<Item>(
                    items: sublist,
                    onChanged: (value) {
                      Item selectItem = value!;
                      setState(() {
                        kind = selectItem;
                      });
                    },
                    value: kind,
                  ),
                  const SizedBox(
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
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueAccent)),
                    child: const Text(
                      '검색하기',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Hero(
                                tag: 'tourinfo$index',
                                child: Container(
                                    margin: EdgeInsets.all(10),
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          color: Colors.black, width: 1),
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image:
                                            getImage(tourData[index].imagePath),
                                      ),
                                    ))),
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 150,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    tourData[index].title!,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('주소 : ${tourData[index].address}'),
                                  tourData[index].tel != null
                                      ? Text('전화번호 : ${tourData[index].tel}')
                                      : Container(),
                                ],
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TourDetailPage(
                                    tourData: tourData[index],
                                    index: index,
                                    databaseReference: widget.databaseReference,
                                    id: widget.id,
                                  )));
                        },
                        onDoubleTap: () {
                          insertTour(widget.db!, tourData[index]);
                        },
                      ),
                    );
                  },
                  itemCount: tourData.length,
                  controller: _scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void insertTour(Future<Database> db, TourData info) async {
    final Database database = await db;
    await database
        .insert('place', info.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('즐겨찾기에 추가되었습니다.')));
    });
  }
}
