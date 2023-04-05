import 'dart:html';
import 'dart:typed_data';
 import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:async';
import 'package:vrfirstaid/services/token_service.dart';

var tokenService = TokenService();
int localUserID = -1;
int localUserGroupID = -1;

class ApiProvider {
  final String url = 'localhost:13000';

   void TrySignOut() async {
    tokenService.clearToken();
  }

  Future<http.Response> register(
      String username, String email, String password) async {
    String _path = "/register";
    // print("My token is " + token.getDecodedToken());
    Map<String, String> requestHeaders = {
      'Authorization': await tokenService.getMyToken()
    };
    var body = {
      "username": username,
      "email": email,
      "password": password,
    };
    return http.post(Uri.http(url, _path), headers: requestHeaders, body: body);
  }

  Future<http.Response> login(String username, String password) async {
    String _path = "/login";
    // print("My token is " + token.getDecodedToken());
    Map<String, String> requestHeaders = {
      'Authorization': await tokenService.getMyToken()
    };
    var body = {
      "username": username,
      "password": password,
    };
    return http.post(Uri.http(url, _path), headers: requestHeaders, body: body);
  }

  Future<http.Response> checkToken() async {
    String _path = "/checkToken";
    Map<String, String> requestHeaders = {
      'Authorization': await tokenService.getMyToken()
    };
    return http.post(Uri.http(url, _path), headers: requestHeaders);
  }

  Future<http.Response> uploadWebImage(Uint8List imageFile) async {
    print("process to send");

    String _path = "/upload";
    var request = http.MultipartRequest("POST", Uri.http(url, _path));
    var multipartFile = http.MultipartFile.fromBytes('image', imageFile,contentType: new MediaType('image', 'png'),
        filename: "webimage.png");
    request.files.add(multipartFile);
    print("sent file");
    var response = await request.send();
     print("upload done");
    var str_Respose =  await http.Response.fromStream(response);
    return str_Respose;
  }

/*
  String state = "";

  Future<http.Response> getUser() async {
    String _path = "/getUser";
    var mytoken = await tokenService.getMyToken();
    // print("Get user data from " + mytoken);
    Map<String, String> requestHeaders = {'Authorization': mytoken};
    return http.get(Uri.https(url, _path), headers: requestHeaders);
  }

  Future<http.Response> getUserProfile() async {
    String _path = "/getUserProfile";
    var mytoken = await tokenService.getMyToken();
    //  print("Get user data from " + mytoken);
    Map<String, String> requestHeaders = {'Authorization': mytoken};
    return http.get(Uri.https(url, _path), headers: requestHeaders);
  }

  Future<http.StreamedResponse> uploadWebImage(Uint8List imageFile) async {
    print("process to send");
    String _path = "/profile-upload-single";
    var request = http.MultipartRequest("POST", Uri.https(url, _path));
    var multipartFile = http.MultipartFile.fromBytes('profile-file', imageFile,
        filename: "webimage.png");
    request.files.add(multipartFile);
    print("sent file");
    var response = await request.send();
    var imageSouce = "";
    return response;
  }

  Future<http.Response> sendClickInfo(int groupId, int click) async {
    String _path = "/sendClickInfo";
    // print("My token is " + token.getDecodedToken());
    Map<String, String> requestHeaders = {
      'Authorization': await tokenService.getMyToken()
    };
    var body = {"groupID": groupId.toString(), "n_count": click.toString()};
    return http.post(Uri.https(url, _path),
        headers: requestHeaders, body: body);
  }*/

  Future<http.Response> addScenario(var data) async {
    String _path = "/scenario/add";
    Map<String, String> requestHeaders = {
      'Authorization': await tokenService.getMyToken(),
      "Content-Type": "application/json"
    };
    var bodyData = jsonEncode(data);
    return http.post(Uri.http(url, _path),
        headers: requestHeaders, body: bodyData);
  }

  Future<http.Response> getScenarios(int page, String addtionalQuery) async {
    String path = "/scenarios";
    return http.get(Uri.http(
        url, path, {"page": page.toString(), "query": addtionalQuery}));
  }

  Future<http.Response> getUserScenarios(int page) async {
    String path = "/scenario/user";
    Map<String, String> requestHeaders = {
      'Authorization': await tokenService.getMyToken(),
    };
    return http.get(Uri.http(url, path, {"page": page.toString()}),headers: requestHeaders,);
  }
/*
  Future<http.Response> getHistory(int userid) async {
    String _path = "/myRewardHistory";
    var mytoken = await tokenService.getMyToken();
    //  print("Get user data from " + mytoken);
    Map<String, String> requestHeaders = {'Authorization': mytoken};
    Map<String, String> params = {'userID': userid.toString()};
    return http.get(Uri.https(url, _path, params), headers: requestHeaders);
  }*/
}
