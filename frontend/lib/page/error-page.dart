import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Object? error;
  ErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Text(error.toString()),
      ),
    );
  }
}