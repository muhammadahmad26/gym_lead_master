import 'package:flutter/material.dart';

class AdminMessageScreen extends StatefulWidget {
  const AdminMessageScreen({super.key});

  @override
  State<AdminMessageScreen> createState() => _AdminMessageScreenState();
}

class _AdminMessageScreenState extends State<AdminMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Hi Message Page")));
  }
}
