// API Side
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:http/io_client.dart';

// Model Side
import 'dart:convert';

// String url = 'URL';

Future<http.Response> getApplicationsAPICall(
    CurrencyRequestModel post, String url) async {
  bool trustSelfSigned = true;
  HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => trustSelfSigned);
  IOClient ioClient = new IOClient(httpClient);

  final response = await ioClient.post(Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        //HttpHeaders.authorizationHeader: '',
      },
      body: currencyRequestToJson(post));
  return response;
}

String currencyRequestToJson(CurrencyRequestModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

CurrencyCommonResponseModel currencyResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return CurrencyCommonResponseModel.fromJson(jsonData);
}

// Request Model
class CurrencyRequestModel {
  String token;

  CurrencyRequestModel({
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        "token": token,
      };
}

class CurrencyCommonResponseModel {
  int code;
  String message;
  final List<CurrencyResponseModel> data;

  CurrencyCommonResponseModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory CurrencyCommonResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<CurrencyResponseModel> dataList =
        list.map((i) => CurrencyResponseModel.fromJson(i)).toList();

    return CurrencyCommonResponseModel(
      code: json["code"] as int,
      message: json["message"] as String,
      data: dataList,
    );
  }
}

class CurrencyResponseModel {
  int id;
  String name;
  String code;

  CurrencyResponseModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CurrencyResponseModel.fromJson(Map<String, dynamic> json) {
    return new CurrencyResponseModel(
      id: json["id"] as int,
      name: json["name"] as String,
      code: json["code"] as String,
    );
  }
}
