
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ColorButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onClick; // Notice the variable type

  ColorButton(this.text,this.color, this.onClick,this.textColor );

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onClick,
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color),
        child: Center(
          child: Text(
                  text,
                  style: TextStyle(
                    color: textColor ,
                    fontSize: 20,
                  ),
                ),
        ),
    ),
  );
  }
}