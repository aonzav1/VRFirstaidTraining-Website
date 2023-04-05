import 'dart:async';
import 'dart:convert';
import 'package:jose/jose.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  TokenService();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  getDecodedToken() async {
    final SharedPreferences prefs = await _prefs;
    final hidedToken = prefs.getString('token') ?? "";
    if (hidedToken == "") {
      return Null;
    }

    var jwt = JsonWebToken.unverified(hidedToken);
    return jwt.claims.toJson();
  }

  Future<String> getMyToken() async {
    final SharedPreferences prefs = await _prefs;
    // print(prefs.getString('token') ?? '');

    return prefs.getString('token') ?? '';
  }

  void setMyToken(String token) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('token', token);
  }

  void clearToken() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString("token", "");
  }

  /// ----------------------------------------------------------
  /// Method that saves the token in Shared Preferences
  /// ----------------------------------------------------------
}
