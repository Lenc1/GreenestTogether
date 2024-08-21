import 'package:flutter/material.dart';
import 'package:get/get.dart';  // 用于使用 Obx
import 'package:dio/dio.dart';
import 'package:local_app/pages/quiz/quiz_menu.dart';
import 'package:local_app/pages/register.dart';
import 'dart:convert';
import '../theme/global.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxString errorMessage = ''.obs; // 用于显示错误信息
  bool isLoading = false; // 用于加载指示器

  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.110.159:5000/api',
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
    followRedirects: true,
    validateStatus: (status) => status! < 500,
  ));

  void _login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = "用户名或密码不能为空";
      return;
    }

    setState(() {
      isLoading = true;
    });

    // 构建请求体
    Map<String, dynamic> data = {
      "username": username,
      "password": password,
    };

    try {
      // 发送POST请求到服务器
      print(username);
      print(password);
      print(json.encode(data));

      final response = await dio.post(
        '/login', // 这里的路径将与 baseUrl 结合
        data: json.encode(data),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Response: ${response.data}');
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success']) {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuizMenuPage()));
          errorMessage.value = "登录成功！";
        } else {
          errorMessage.value = responseData['message'] ?? "用户名或密码错误";
        }
      } else {
        errorMessage.value = "服务器错误，请稍后再试";
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      setState(() {
        isLoading = false;
      });

      if (e.response != null) {
        errorMessage.value = e.response?.data['message'] ?? "服务器错误，请稍后再试";
      } else {
        errorMessage.value = "网络错误，请检查您的连接";
      }
    } catch (e) {
      print('Unknown Error: $e');
      setState(() {
        isLoading = false;
      });
      errorMessage.value = "未知错误，请稍后再试";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 60),
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Obx(
                    () => Text(
                  "欢迎登录",
                  style: TextStyle(
                    color: GlobalService.to.isDarkModel ? Colors.white : Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
                child: Text("没有账户？点击注册"),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), // 设置圆角半径
              ),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25), // 与 Container 的圆角一致
                  ),
                  labelText: '  用户名',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), // 设置圆角半径
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25), // 与 Container 的圆角一致
                  ),
                  labelText: '  密码',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
                  () => errorMessage.value.isNotEmpty
                  ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  errorMessage.value,
                  style: TextStyle(color: Colors.red),
                ),
              )
                  : SizedBox.shrink(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () {
                  // 忘记密码的逻辑
                },
                child: Text('忘记密码？'),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                  width: 24, // 设置加载动画的宽度
                  height: 24, // 设置加载动画的高度
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0, // 设置加载动画的线条宽度
                  ),
                )
                    : Icon(Icons.arrow_forward_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
