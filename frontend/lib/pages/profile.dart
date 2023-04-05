import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vrfirstaid/classes/scenarioData.dart';
import 'package:vrfirstaid/core/app_style.dart';
import 'package:vrfirstaid/main.dart';
import 'package:vrfirstaid/services/apiprovider.dart';
import 'package:vrfirstaid/widgets/colorbutton.dart';
import 'package:vrfirstaid/widgets/scenario_list_view.dart';

import '../core/app_data.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

var username = "";

class _ProfilePageState extends State<ProfilePage> {
  var apiProvider = ApiProvider();
  bool circular = true;

  loadProfile() async {
    var token = await tokenService.getMyToken();
    if (token != null) {
      var result = await apiProvider.checkToken();
      if (result.statusCode == 200) {
        isLoggedIn = true;
        username = result.body;
        print("Currently logged in");
      } else {
        isLoggedIn = false;
        print("NULL TOKEN");
      }
    } else {
      isLoggedIn = false;
    }
    setState(() {
      circular = false;
    });
  }

  @override
  void initState() {
    super.initState();
    circular = true;
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return circular
        ? const Text(
            'Loading...',
            textAlign: TextAlign.center,
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: isLoggedIn ? LoggedInView() : NotLoggedInView(),
            ),
          );
  }
}

class NotLoggedInView extends StatelessWidget {
  const NotLoggedInView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 160),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(
              "You're not logged in",
              style: Theme.of(context).textTheme.headline1,
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 240,
              child: ColorButton(
                  "Login",
                  Theme.of(context).primaryColor,
                  () => {Navigator.pushNamed(context, "/login")},
                  Colors.white)),
          Container(
              width: 240,
              child: ColorButton(
                  "Register",
                  Theme.of(context).primaryColor,
                  () => {Navigator.pushNamed(context, "/register")},
                  Colors.white)),
        ],
      ),
    );
  }
}

class LoggedInView extends StatefulWidget {
  const LoggedInView({
    Key? key,
  }) : super(key: key);

  @override
  State<LoggedInView> createState() => _LoggedInViewState();
}

class _LoggedInViewState extends State<LoggedInView> {
  Future<List<ScenarioData>>? _futureScenarios;
  var apiProvider = ApiProvider();

  logout() {
    apiProvider.TrySignOut();
    isLoggedIn = false;
    Navigator.pushNamedAndRemoveUntil(context, "/", (route) => true);
  }

  Future<List<ScenarioData>> getScenarios() async {
    final result = await apiProvider.getUserScenarios(0);
    if (result.statusCode == 200) {
      var data = jsonDecode(result.body)["data"];
      List<ScenarioData> res = data == null
          ? []
          : List<ScenarioData>.from(data.map((i) => ScenarioData.fromJson(i)));
      return res;
    } else {
      print(result.body);
      throw Exception('Failed to fetch scenarios');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureScenarios = getScenarios();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 560,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Welcome, " + username,
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 240,
                child: ColorButton("Logout", Theme.of(context).primaryColor,
                    logout, Colors.white)),
            const SizedBox(
              height: 12,
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: Text(
                  "Your created scenario",
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.left,
                )),
            (_futureScenarios == null) ? Container() : buildFutureBuilder(),
            Container(
              height: 150,
            )
          ],
        ),
      ),
    );
  }

  FutureBuilder<List> buildFutureBuilder() {
    return FutureBuilder<List<ScenarioData>>(
      future: _futureScenarios,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ScenarioListView(
            scenarioList: snapshot.data!,
            isHorizontal: false,
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
