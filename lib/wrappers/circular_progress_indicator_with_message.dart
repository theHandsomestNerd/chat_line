import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CircularProgressIndicatorWithMessage extends StatelessWidget {
  const CircularProgressIndicatorWithMessage({Key? key, this.message}) : super(key: key);

  final String? message;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16,),
        Text(message??""),
      ],
    );
  }
}
