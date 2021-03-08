import 'package:flutter/material.dart';

class ExpandedButton extends StatelessWidget {
  final String buttonText;
  final Color backgroundColor;
  final Color textColor;
  final Function onPressed;

  const ExpandedButton({
    Key key,
    this.buttonText = "Button",
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.black,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: TextButton(
          onPressed: onPressed,
          child: Center(
            child: Text(buttonText),
          ),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => backgroundColor),
            foregroundColor:
                MaterialStateProperty.resolveWith((states) => textColor),
          ),
        ),
      ),
    );
  }
}
