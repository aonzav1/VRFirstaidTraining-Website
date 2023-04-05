import 'dart:async';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  var apiProvider = ApiProvider();
  Future<List<ScenarioData>>? _futureScenarios;
  Timer? _debounce;

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _futureScenarios = getScenarios(query);
      });
    });
  }

  Widget _searchBar() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: const Icon(Icons.menu, color: Colors.grey),
            contentPadding: const EdgeInsets.all(20),
            border: textFieldStyle,
            focusedBorder: textFieldStyle,
          ),
          onChanged: _onSearchChanged,
        ));
  }

  Future<List<ScenarioData>> getScenarios(String queryText) async {
    var customQuery = "WHERE name LIKE '%$queryText%'";
    if (queryText == "") {
      customQuery = "";
    }
    final result = await apiProvider.getScenarios(0, customQuery);
    if (result.statusCode == 200) {
      var data = (jsonDecode(result.body))["data"];
      List<ScenarioData> res = data == null
          ? []
          : List<ScenarioData>.from(data.map((i) => ScenarioData.fromJson(i)));
      return res;
    } else {
      throw Exception('Failed to fetch scenarios');
    }
  }

  var longText =
      "      The most common cause of death in the world comes from accidents. But many deaths did not die at the scene. One of common mistakes is that people at the event didn't know what they should do. The solution of this problem is “Training”. VR First Aid Training contains interactive first-aid lessons and simulations. You can learn and gain experience by practicing without requiring any simulation dolls or instructors. Learning and practicing can be done anywhere and anytime. Gain immersive experience of first aid training now.";
  //var longText2 = "     VR First Aid Training contains interactive first-aid lessons and simulations. You can learn and gain experience by practicing without requiring any simulation dolls or instructors. Learning and practicing can be done anywhere and anytime. Gain immersive experience of first aid training now.";

  @override
  void initState() {
    super.initState();
    _futureScenarios = getScenarios("");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 160),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "+",
                style: TextStyle(
                    fontSize: 210.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                "VR First Aid Training",
                style: Theme.of(context).textTheme.headline3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "By Burapa Phatichon",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 180),
                child: Text(
                  longText,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              //Container(child :Text(longText2,style: Theme.of(context).textTheme.bodyText2,),padding:EdgeInsets.symmetric(vertical:12, horizontal: 180)),
              Container(
                  margin: const EdgeInsets.all(24),
                  width: 240,
                  child: ColorButton(
                      "Visit store",
                      Theme.of(context).primaryColor,
                      (() => {}),
                      Colors.white)),

              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
                child: Text("Contact: aon3975@gmail.com",
                    style: Theme.of(context).textTheme.bodyText1),
              ),

              Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox(width: 640, child: _searchBar())),

              Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: double.infinity,
                  child: Text(
                    "Scenarios from our community",
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
            isHorizontal: true,
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
