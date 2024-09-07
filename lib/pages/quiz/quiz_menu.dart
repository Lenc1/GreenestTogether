import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_app/config/global_preference.dart';

class QuizMenuPage extends StatefulWidget {
  const QuizMenuPage({super.key});

  @override
  State<QuizMenuPage> createState() => _QuizMenuPageState();
}

class _QuizMenuPageState extends State<QuizMenuPage> {
  List<Map<String, dynamic>> questions = []; // 用于存储题目和选项
  bool isLoading = false; // 是否正在加载
  bool isQuizStarted = false; // 用于控制是否开始答题
  String errorMessage = ''; // 错误信息
  int remainingChances = 0; // 用户剩余的答题机会
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: API.reqUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  void initState() {
    super.initState();
    _fetchChances();
  }

  // 获取用户剩余的答题机会
  Future<void> _fetchChances() async {
    String? token = await secureStorage.read(key: 'authToken');
    print("token ${token}");
    if (token != null && token.isNotEmpty) {
      try {
        dio.options.headers['Authorization'] = token;
        final response = await dio.get('/get_remaining_chances');
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            remainingChances = response.data['remaining_chances'];
          });
        } else {
          setState(() {
            errorMessage = '无法获取答题机会，请稍后再试';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = '网络错误，请检查您的连接';
        });
      }
    }
  }

  // 获取题目并检查答题机会
  Future<void> _fetchQuestions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // 获取当前用户的答题机会
    await _fetchChances();

    // 检查是否有剩余答题机会
    if (remainingChances <= 0) {
      setState(() {
        errorMessage = '您没有剩余的答题机会了';
        isLoading = false;
      });
      return;
    }

    try {
      String? token = await secureStorage.read(key: 'authToken');
      final response = await dio.post(
        '/generate_daily_questions',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // 添加 Token 到请求头
          },
        ),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        setState(() {
          questions =
              List<Map<String, dynamic>>.from(responseData['questions']);
          isQuizStarted = true; // 成功加载后，开始答题
        });
      } else {
        setState(() {
          errorMessage = '无法获取题目，请稍后再试';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '网络错误，请检查您的连接';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 提交答案后减少一次答题机会
  Future<void> _reduceChance() async {
    try {
      String? token = await secureStorage.read(key: 'authToken');
      final response = await dio.post(
        '/reduce_chance',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token, // 添加 Token 到请求头
          },
        ),
      );

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = '无法更新答题机会，请稍后再试';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '网络错误，请检查您的连接';
      });
    }
  }

  // 提交答案后增加积分
  Future<void> _addPoint(int score) async {
    try {
      String? token = await secureStorage.read(key: 'authToken');
      final response = await dio.post(
        '/add_score',
        data: {'score': score},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token, // 添加 Token 到请求头
          },
        ),
      );

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = '无法增加分数，请稍后再试';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '网络错误，请检查您的连接';
      });
    }
  }

  // 提交答案并处理得分和机会
  void _submitAnswers() {
    // 检查是否有未选择的选项
    bool hasUnansweredQuestions = questions.any(
      (question) => question['selectedOption'] == null,
    );

    if (hasUnansweredQuestions) {
      // 如果有未回答的问题，弹出提示
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('提示'),
            content: const Text('您还有未完成的题目，请选择答案。'),
            actions: <Widget>[
              TextButton(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭提示框
                },
              ),
            ],
          );
        },
      );
    } else {
      // 如果所有问题都已回答，计算得分
      int score = 0;
      List<Map<String, dynamic>> wrongAnswers = []; // 错题列表

      for (var question in questions) {
        if (question['selectedOption'] == question['correct_option']) {
          score++;
        } else {
          wrongAnswers.add(question); // 记录答错的题目
        }
      }
      _addPoint(score * 2);
      // 显示得分弹窗并减少一次答题机会
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('答题结果'),
            content: Text(
                '您的得分是 $score/${questions.length}\n恭喜您，本次获得${score * 2}个积分！'),
            actions: <Widget>[
              TextButton(
                child: const Text('查看错题'),
                onPressed: () async {
                  await _reduceChance(); // 减少一次答题机会
                  Navigator.of(context).pop(); // 关闭弹窗
                  _showWrongAnswers(wrongAnswers); // 显示错题详情
                },
              ),
              TextButton(
                child: const Text('确定 '),
                onPressed: () async {
                  await _reduceChance(); // 减少一次答题机会
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizMenuPage(), // 重新加载当前页面
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }

  //显示错误答案
  void _showWrongAnswers(List<Map<String, dynamic>> wrongAnswers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错题详情'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: wrongAnswers.length,
              itemBuilder: (context, index) {
                final question = wrongAnswers[index];
                return ListTile(
                  title: Text('题目: ${question["description"]}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '您的答案: ${question["options"][question["selectedOption"]! - 1]}'),
                      Text(
                          '正确答案: ${question["options"][question["correct_option"] - 1]}'),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QuizMenuPage()));
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('答题中心'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!isQuizStarted && remainingChances > 0)
              GestureDetector(
                onTap:
                    isLoading || remainingChances <= 0 ? null : _fetchQuestions,
                child: Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ansq.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12), // 设置圆角
                  ),
                ),
              ),
            if (!isQuizStarted && remainingChances == 0)
              GestureDetector(
                onTap:
                isLoading || remainingChances > 0 ? null : _fetchQuestions,
                child: Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ubansq.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(12), // 设置圆角
                  ),
                ),
              ),
            if (remainingChances >= 0) Text('剩余答题机会：$remainingChances'),
            const SizedBox(height: 20),
            if (!isQuizStarted) SizedBox(height: 100),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (questions.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '题目 ${index + 1}: ${question["description"]}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ...List.generate(question['options'].length,
                                (optionIndex) {
                              return RadioListTile<int>(
                                title: Text(question['options'][optionIndex]),
                                value: optionIndex + 1,
                                groupValue: question['selectedOption'],
                                onChanged: (value) {
                                  setState(() {
                                    question['selectedOption'] = value;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _submitAnswers,
                child: const Text('提交答案'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
