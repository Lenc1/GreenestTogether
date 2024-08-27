import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxString errorMessage = ''.obs; // 用于显示错误信息
  bool isLoading = false; // 用于加载指示器
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://112.124.62.169:5000/api',
    connectTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20),
  ));

  void _register() async {
    String username = usernameController.text;
    String password = passwordController.text;
    String email = emailController.text;

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
      "email": email,
    };

    try {
      // 发送POST请求到服务器
      print("发送注册请求");
      print(json.encode(data));
      final response = await dio.post(
        '/register',
        data: json.encode(data),
      );

      print('Response: ${response.data}');
      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['success']) {
          errorMessage.value = "注册成功！请登录。";
          Navigator.pop(context);  // 注册成功后返回登录页面
        } else {
          errorMessage.value = responseData['message'] ?? "注册失败";
        }
      } else if (response.statusCode == 409) {
        errorMessage.value = "用户名已存在";
      } else {
        errorMessage.value = "服务器错误，请稍后再试";
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.response}');
      setState(() {
        isLoading = false;
      });
      if (e.response != null) {
        errorMessage.value = e.response?.data['message'] ?? "服务器错误，请稍后再试";
      } else {
        errorMessage.value = "网络错误，请检查您的连接";
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      errorMessage.value = "未知错误，请稍后再试";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("注册"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 60),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "创建账户",
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), // 设置圆角半径
              ),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25), // 与 Container 的圆角一致
                  ),
                  labelText: '  邮箱（可选）',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
                  () => errorMessage.value.isNotEmpty
                  ? Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              )
                  : const SizedBox.shrink(),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading
                    ? const SizedBox(
                  width: 24,  // 设置加载动画的宽度
                  height: 24, // 设置加载动画的高度
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,  // 设置加载动画的线条宽度
                  ),
                )
                    : const Text('注册'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
