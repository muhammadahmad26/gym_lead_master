import 'package:flutter/material.dart';

class AdminPymentPage extends StatefulWidget {
  const AdminPymentPage({super.key});

  @override
  State<AdminPymentPage> createState() => _AdminPymentPageState();
}

class _AdminPymentPageState extends State<AdminPymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Hi PayMent")),
    );
  }
}