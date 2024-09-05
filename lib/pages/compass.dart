import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('垃圾分类投放指南'),
      ),
      body: Center(
        child: const ClipRRect(
          child: Image(image: const AssetImage('assets/images/compass.png')),
        ),
      ),
    );
  }
}
