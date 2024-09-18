import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:local_app/pages/useless/about.dart';
import 'package:local_app/pages/useless/compass.dart';
import 'package:local_app/pages/login/login.dart';
import 'package:local_app/pages/map.dart';
import 'package:local_app/pages/quiz/quiz_menu.dart';
import 'package:local_app/config/settings.dart';
import 'package:local_app/pages/sort.dart';
import 'package:local_app/pages/useless/suggestion.dart';
import 'package:local_app/pages/user/user.dart';
import 'package:local_app/theme/global.dart';
import 'package:local_app/theme/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/global_preference.dart';

void main() {
  appInit();
}

appInit() async {
  await Hive.initFlutter();
  await Hive.openBox('recognitionHistory');
  WidgetsFlutterBinding.ensureInitialized();
  Get.put<GlobalService>(GlobalService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(), // 检查是否存在Token
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          // 根据Token存在与否导航到不同页面
          return GetMaterialApp(
            title: '怀智共游',
            theme:
                GlobalService.to.isDarkModel ? AppTheme.dark : AppTheme.light,
            home: snapshot.data == true
                ? const MyHomePage(title: '')
                : const LoginPage(), // 如果没有Token，导航到登录页面
          );
        }
      },
    );
  }

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

void requestPermission() async {
  bool hasLocationPermission = await requestLocationPermission();
  if (hasLocationPermission) {
    print("定位权限申请通过"); //de8g
  } else {
    print("定位权限申请不通过");
  }
}

Future<bool> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (status == PermissionStatus.granted) {
    return true;
  } else {
    status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? _username;
  int? _userpoint;
  bool isLoading = false; // 用于标识是否正在加载
  String _avatarPath = '';

  @override
  void initState() {
    super.initState();
    requestPermission();
    _fetchUsername();
    _loadAvatarPath();
  }

  Future<void> _loadAvatarPath() async {
    // 从本地存储中读取头像路径并更新UI
    String? avatarPath = await secureStorage.read(key: 'avatarPath');
    setState(() {
      _avatarPath = avatarPath ?? ''; // 如果路径不存在，设置为空字符串
    });
  }

  Future<void> _fetchUsername() async {
    setState(() {
      isLoading = true; // 开始加载
    });
    String? token = await secureStorage.read(key: 'authToken');
    Dio dio = Dio(BaseOptions(baseUrl: API.reqUrl));
    if (token != null && token.isNotEmpty) {
      try {
        dio.options.headers['Authorization'] = token; // 将token添加到请求头中
        final response = await dio.get('/get_nickname');
        if (response.statusCode == 401) {
          await secureStorage.delete(key: 'authToken');
        }
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            _username = response.data['nickname']; // 保存用户名
          });
        }
      } catch (e) {
        print('Failed to fetch username: $e');
      }
      try {
        dio.options.headers['Authorization'] = token; // 将token添加到请求头中
        final response = await dio.get('/get_score');
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            _userpoint = response.data['score']; // 保存积分
          });
        }
      } catch (e) {
        Navigator.pop(context);
        print('Failed to fetch username: $e');
      }
    }

    setState(() {
      isLoading = false; // 加载完成
    });
  }

  Future<void> _onRefresh() async {
    await _fetchUsername(); // 调用获取数据的函数
    await _loadAvatarPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Obx(
          () => RefreshIndicator(
            color: GlobalService.to.isDarkModel
                ? const Color(0xFF2F2E33) // 黑暗模式下的背景颜色
                : Colors.white70, // 亮模式下的背景颜色,
            onRefresh: _onRefresh, // 下拉刷新调用的函数
            child: ListView(
              padding: const EdgeInsets.fromLTRB(5, 3, 20, 0), // 去除顶部的padding
              children: [
                Container(
                  // color: GlobalService.to.isDarkModel
                  //     ? const Color(0xFF2F2E33) // 黑暗模式下的背景颜色
                  //     : Colors.white70, // 亮模式下的背景颜色
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
                              onPressed: () =>
                                  GlobalService.to.switchThemeModel(),
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserPage()));
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
                            child: Row(
                              children: [
                                ClipOval(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: _avatarPath.isNotEmpty
                                        ? Image.file(
                                            File(_avatarPath),
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/images/logo.png',
                                            width: 60,
                                            height: 60,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10), // 图片和文本之间的间距
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _username ?? '加载中...',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text('Lv${(_userpoint?.toInt() ?? 0)~/10}  '),
                                        Text(
                                          '当前积分: ${_userpoint?.toString() ?? '加载中...'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )

                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CompassPage()));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // 圆角效果
                          ),
                          color: GlobalService.to.isDarkModel
                              ? Colors.white10
                              : Colors.white,
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Icon(Icons.class_outlined),
                                SizedBox(width: 10),
                                Text(
                                  "分类投放指南",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AboutUsPage()));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // 圆角效果
                          ),
                          color: GlobalService.to.isDarkModel
                              ? Colors.white10
                              : Colors.white,
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Icon(Icons.people_alt_outlined),
                                SizedBox(width: 10),
                                Text(
                                  "关于我们",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SuggestionPage()));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // 圆角效果
                          ),
                          color: GlobalService.to.isDarkModel
                              ? Colors.white10
                              : Colors.white,
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined),
                                SizedBox(width: 10),
                                Text(
                                  "意见建议",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsPage()));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0), // 圆角效果
                          ),
                          color: GlobalService.to.isDarkModel
                              ? Colors.white10
                              : Colors.white,
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Icon(Icons.settings_outlined),
                                SizedBox(width: 10),
                                Text(
                                  "设置",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh, // 下拉刷新时调用的函数
        child: isLoading // 根据isLoading状态显示不同的内容
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Obx(
                      () => Image(
                        image: GlobalService.to.isDarkModel
                            ? const AssetImage('assets/images/MEH.png')
                            : const AssetImage('assets/images/MEH.png'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MapPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("碳索世界"),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SortPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text("智能分类"),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () async {
                      String? token =
                          await secureStorage.read(key: 'authToken');
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
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    label: const Text("答题中心"),
                    icon: const Icon(Icons.quiz_outlined),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
