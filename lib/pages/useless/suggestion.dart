import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _suggestionController = TextEditingController(); // 单独的控制器用于意见建议
  final TextEditingController _contactController = TextEditingController(); // 单独的控制器用于联系方式

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('意见建议'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '请留下您的意见和建议:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _suggestionController, // 用于意见建议的控制器
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '输入您的意见和建议',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '联系方式:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contactController, // 用于联系方式的控制器
                maxLines: 1,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '输入您的联系方式',
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: () {
                      // 获取输入框内容
                      String suggestion = _suggestionController.text.trim();
                      String contact = _contactController.text.trim();

                      if (suggestion.isEmpty || contact.isEmpty) {
                        // 输入框内容为空时弹窗提示
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('提示'),
                              content: const Text('有内容还没有输入哦。'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('确定'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // 输入框内容不为空时弹窗提示提交成功
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('提交成功'),
                              content: const Text('感谢您的反馈！'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // 关闭提示框后，清除输入框内容
                                    Navigator.of(context).pop();
                                    _suggestionController.clear();
                                    _contactController.clear();
                                  },
                                  child: const Text('确定'),
                                ),
                              ],
                            );
                          },
                        );

                        // 这里可以处理提交的逻辑，比如发送到服务器
                        print('意见: $suggestion, 联系方式: $contact');
                      }
                    },
                    child: const Text('提交'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
