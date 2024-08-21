import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuizMenuPage extends StatefulWidget {
  const QuizMenuPage({super.key});

  @override
  State<QuizMenuPage> createState() => _QuizMenuPageState();
}

class _QuizMenuPageState extends State<QuizMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录成功'),
      ),
    );
  }
}
