import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vrfirstaid/main.dart';
import 'package:vrfirstaid/services/apiprovider.dart';
import 'package:vrfirstaid/services/token_service.dart';
import 'package:vrfirstaid/widgets/colorbutton.dart';
import 'package:vrfirstaid/widgets/textItem.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  var apiProvider = ApiProvider();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  bool circular = false;

  login() async {
    try {
      var result = await apiProvider.login(
          _usernameController.text, _pwdController.text);
      if (result == null) return;
      var data = jsonDecode(result.body);
      if (data['token'] == null) {
        final snackbar = SnackBar(content: Text(data['message']));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        setState(() {
          circular = false;
        });
        return;
      }
      tokenService.setMyToken(data['token']);
      isLoggedIn = true;
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => true);
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      setState(() {
        circular = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return circular
        ? const Text(
            'Logging In...',
            textAlign: TextAlign.center,
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 512,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Login",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        TextItem("Username....", _usernameController, false, () {}),
                        const SizedBox(
                          height: 15,
                        ),
                        TextItem("Password...", _pwdController, true, () {}),
                        const SizedBox(
                          height: 40,
                        ),
                        ColorButton("Login", Theme.of(context).primaryColor, login,
                            Colors.white),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "If you don't have an Account? ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/register', (route) => true);
                              },
                              child: const Text(
                                "SignUp",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget buttonItem(
      String imagepath, String buttonName, double size, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        child: Card(
          color: Colors.black,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                imagepath,
                height: size,
                width: size,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                buttonName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
