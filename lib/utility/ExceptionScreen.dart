import 'dart:io';
import 'package:flutter/material.dart';

class ExceptionScreen extends StatelessWidget {
  final String errorMessage;
  final String errorCode;
  final bool shouldExit;

  const ExceptionScreen({
    Key? key,
    required this.errorMessage,
    required this.errorCode,
    this.shouldExit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 35),
              Image.asset(
                'images/ic_error.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontFamily: 'OpenSans',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (shouldExit) {
                    exit(0); // 🔴 This exits the app completely
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
