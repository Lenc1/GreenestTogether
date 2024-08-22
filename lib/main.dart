import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:local_app/pages/location.dart';
import 'package:local_app/pages/login.dart';
import 'package:local_app/pages/map.dart';
import 'package:local_app/pages/quiz/quiz_menu.dart';
import 'package:local_app/pages/settings.dart';
import 'package:local_app/pages/sort.dart';
import 'package:local_app/pages/user/user.dart';
import 'package:local_app/theme/global.dart';
import 'package:local_app/theme/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// 删除 'package:shared_preferences/shared_preferences.dart';

void main() {
  appInit();
}

appInit() async {
  await Hive.initFlutter();
  await Hive.openBox('recognitionHistory');
  WidgetsFlutterBinding.ensureInitialized();
  // service全局注入
  Get.put<GlobalService>(GlobalService());
  // 启动app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 初始化 FlutterSecureStorage
  static final FlutterSecureStorage secureStorage =
      const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(), // 检查是否存在Token
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 显示加载指示器
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          // 根据Token存在与否导航到不同页面
          return GetMaterialApp(
            title: '净智同心创意APP设计',
            theme:
                GlobalService.to.isDarkModel ? AppTheme.dark : AppTheme.light,
            home: snapshot.data == true
                ? const MyHomePage(title: '首页')
                : const LoginPage(), // 如果没有Token，导航到登录页面
          );
        }
      },
    );
  }

  // 检查是否存在Token
  static Future<bool> _hasToken() async {
    String? token = await secureStorage.read(key: 'authToken');
    return token != null && token.isNotEmpty;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? _username;
  int? _userpoint;

  @override
  void initState() {
    super.initState();
    _fetchUsername(); //初始化时加载用户名
  }

  Future<void> _fetchUsername() async {
    String? token = await secureStorage.read(key: 'authToken');
    if (token != null && token.isNotEmpty) {
      try {
        Dio dio = Dio();
        dio.options.headers['Authorization'] = token; // 将token添加到请求头中
        final response =
            await dio.get('http://192.168.110.159:5000/api/get_username');
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            _username = response.data['username']; // 保存用户名
          });
        }
      } catch (e) {
        print('Failed to fetch username: $e');
      }
      try {
        Dio dio = Dio();
        dio.options.headers['Authorization'] = token; // 将token添加到请求头中
        final response =
            await dio.get('http://192.168.110.159:5000/api/get_score');
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            _userpoint = response.data['score']; //保存积分
          });
        }
      } catch (e) {
        print('Failed to fetch username: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Obx(
          () => Container(
            color: GlobalService.to.isDarkModel
                ? const Color(0xFF2F2E33) // 黑暗模式下的背景颜色
                : Colors.white70, // 亮模式下的背景颜色
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 30, 20, 0),
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          foregroundColor: GlobalService.to.isDarkModel
                              ? Colors.black87
                              : Colors.white,
                          backgroundColor: GlobalService.to.isDarkModel
                              ? Colors.white
                              : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        onPressed: () => GlobalService.to.switchThemeModel(),
                        child: Obx(
                          () => Icon(
                            GlobalService.to.isDarkModel
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserPage())
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15.0), // 设置卡片的圆角效果
                          ),
                          color: GlobalService.to.isDarkModel
                              ? Colors.white10
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            // 设置卡片内部的填充
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Image(
                                    image: GlobalService.to.isDarkModel
                                        ? const AssetImage(
                                            'assets/images/darkcat.png')
                                        : const AssetImage(
                                            'assets/images/logo.png'),
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                                const SizedBox(width: 10), // 图片和文本之间的间距
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_username!,style: const TextStyle(
                                      fontSize: 20
                                    ),),
                                    const SizedBox(height: 5),
                                    Text('当前积分:${_userpoint.toString()}', style: const TextStyle(
                                      fontSize: 14,
                                    ),),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap:(){
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsPage())
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15.0), // 设置卡片的圆角效果
                          ),
                          color: GlobalService.to.isDarkModel
                              ? Colors.white10
                              : Colors.white,
                          child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              // 设置卡片内部的填充
                              child: Row(
                                children: [
                                  Icon(Icons.settings),
                                  const SizedBox(width: 10),
                                  Text("设置",style: TextStyle(fontSize: 15),),
                                ],
                              )
                          ),
                        ),
                      ),
                      // 在这里添加更多的 ListTile 或其他内容
                    ],
                  ),
                ),
                FutureBuilder<String?>(
                  future: secureStorage.read(key: 'authToken'),
                  // 从SecureStorage读取Token
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink(); // 显示空白或加载动画
                    }
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return ListTile(
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "退出登录 ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                            Icon(Icons.logout),
                          ],
                        ),
                        onTap: () async {
                          await secureStorage.delete(
                              key: 'authToken'); // 从SecureStorage删除Token
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                            (route) => false,
                          );
                        },
                      );
                    } else {
                      return const SizedBox.shrink(); // 如果没有 token，则不显示登出按钮
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.menu,
              semanticLabel: 'menu',
            ),
          ),
        ),
        title: Text(''), // 可以在AppBar中显示用户名
        // actions: <Widget>[
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: Center(
        //       child: Text(_username ?? '', style: TextStyle(fontSize: 16)),
        //     ),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(90.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 200,
              width: 100,
              child: ClipOval(
                child: Obx(
                  () => Image(
                    image: GlobalService.to.isDarkModel
                        ? const AssetImage('assets/images/darkcat.png')
                        : const AssetImage('assets/images/logo.png'),
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              child: const Text("绿色出行"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SortPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              child: const Text("智能分类"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? token = await secureStorage.read(key: 'authToken');
                if (token != null && token.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuizMenuPage()),
                  );
                } else {
                  // 如果没有Token，导航到登录页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              child: const Text("答题中心"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
