import 'package:flutter/material.dart';

Future<void> ShowSuccessDialog(String message,var context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Success',textAlign:TextAlign.center,style:  TextStyle(
              fontSize: 36.0,
              fontStyle: FontStyle.normal,
              color: Colors.black87)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Icon(Icons.check_circle_outline,color: Colors.green,size:96,),
              SizedBox(height: 12,),
              Text(textAlign:TextAlign.center,message),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(textAlign:TextAlign.center,'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}