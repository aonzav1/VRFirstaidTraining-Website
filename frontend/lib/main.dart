import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vrfirstaid/pages/creator.dart';
import 'package:vrfirstaid/pages/profile.dart';
import 'package:vrfirstaid/widgets/BNBCustomePainter.dart';

import 'pages/home.dart';
import 'pages/authentication/login.dart';
import 'pages/authentication/register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}
bool isLoggedIn = false;
int selectedIndex = 0;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VR FirstAid Training',
      initialRoute: '/',
      theme: ThemeData(
        // Define the default brightness and colors.
        // brightness: Brightness.dark,
        primaryColor: Color(0xFFC6403F),
        primarySwatch: Colors.grey,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(primary: Color(0xFFC6403F)),
        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          headline1: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
          headline2: TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
          headline3: TextStyle(
              fontSize: 54.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
          headline6: TextStyle(
              fontSize: 36.0,
              fontStyle: FontStyle.italic,
              color: Colors.black87),
          bodyText1: TextStyle(
              fontSize: 14.0, fontFamily: 'Hind', color: Colors.black87),
          bodyText2: TextStyle(
              fontSize: 16.0, fontFamily: 'Hind', color: Colors.black87),
        ),
      ),
      routes: {
        // '/': (context) => const  MainPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  final List<Widget> _pages = <Widget>[
    HomePage(),
    CreatePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double maxAvailableWidth = min(560, size.width);

    return Scaffold(
      backgroundColor: Colors.white10,
      body: Stack(
        children: [
          Center(child: _pages[selectedIndex]),
          //Bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size.width,
              height: 80,
              child: Stack(
                children: [
                  Center(
                      child: CustomPaint(
                    size: Size(maxAvailableWidth, 80),
                    painter: BNBCustomePainter(),
                  )),
                  Center(
                    heightFactor: 0.6,
                    child: FloatingActionButton(
                      onPressed: () {
                        _onItemTapped(1);
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      elevation: 0.1,
                    ),
                  ),
                  Center(
                      child: Container(
                    width: maxAvailableWidth,
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              _onItemTapped(0);
                            },
                            icon: Icon(
                              Icons.explore,
                              color: Colors.grey.shade700,
                            )),
                        Container(
                          width: maxAvailableWidth * .25,
                        ),
                        IconButton(
                            onPressed: () {
                              _onItemTapped(2);
                            },
                            icon: Icon(Icons.person,
                                color: Colors.grey.shade700)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
