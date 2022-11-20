import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> getHttpClientGetApi(String url) async {
  HttpClient client = new HttpClient();
  client.badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true);

  // String url ='xyz@xyz.com';

  // Map map = {
  //   "email" : "email" ,
  //   "password" : "password"
  // };

  HttpClientRequest request = await client.getUrl(Uri.parse(url));

  request.headers.set('content-type', 'application/json');

  // request.add(utf8.encode(json.encode(map)));

  HttpClientResponse response = await request.close();

  // var result = new StringBuffer();
  // await for (var contents in response.transform(Utf8Decoder())) {
  //   result.write(contents);
  // }

  return await response.transform(Utf8Decoder()).join();
  ;

  // return jsonDecode(result.toString());

  // List<dynamic> myList = jsonDecode(result.toString());
  // print(myList);

  // return response.transform(utf8.decoder);

  // return response;
}
