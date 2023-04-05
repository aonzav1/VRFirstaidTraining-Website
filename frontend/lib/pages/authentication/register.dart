import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vrfirstaid/main.dart';
import 'package:vrfirstaid/services/apiprovider.dart';
import 'package:vrfirstaid/services/token_service.dart';
import 'package:vrfirstaid/widgets/colorbutton.dart';
import 'package:vrfirstaid/widgets/textItem.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  var apiProvider = ApiProvider();

  // firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _repwdController = TextEditingController();
  bool circular = false;

  register() async {
    if (_pwdController.text != _repwdController.text) {
      final snackbar = SnackBar(content: Text("Passwords not matched"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return;
    }

    setState(() {
      circular = true;
    });
    try {
      //Try create user
      var result = await apiProvider.register(
          _nameController.text, _emailController.text, _pwdController.text);
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
      setState(() {
        circular = false;
      });
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
            'Registering...',
            textAlign: TextAlign.center,
          )
        :Scaffold(
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
                    "Register",
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  TextItem("Name", _nameController, false, () {}),
                  const SizedBox(
                    height: 15,
                  ),
                  TextItem("Email", _emailController, false, () {}),
                  const SizedBox(
                    height: 15,
                  ),
                  TextItem("Password", _pwdController, true, () {}),
                  const SizedBox(
                    height: 15,
                  ),
                  TextItem("Re-Password", _repwdController, true, () {}),
                  const SizedBox(
                    height: 15,
                  ),
                  ColorButton("Register", Theme.of(context).primaryColor,
                      register, Colors.white),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "If you alredy have an Account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => true);
                        },
                        child: const Text(
                          "Login",
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
