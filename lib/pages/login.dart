import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../theme/global.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("")
      ),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 60),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(1),
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
              child: TextButton(onPressed: (){},
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
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: (){},
                child: Icon(
                  Icons.arrow_forward_rounded,
                ),
              ),
              ),
          ],
        ),
      ),
    );
  }
}
