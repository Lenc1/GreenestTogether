import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:local_app/pages/location.dart';
import 'package:local_app/pages/login.dart';
import 'package:local_app/pages/map.dart';
import 'package:local_app/pages/sort.dart';
import 'package:local_app/theme/global.dart';
import 'package:local_app/theme/theme.dart';

void main() {
  appInit();
}

appInit() async {
  await Hive.initFlutter();
  await Hive.openBox('recognitionHistory');
  WidgetsFlutterBinding.ensureInitialized();
  //service全局注入
  Get.put<GlobalService>(GlobalService());
  //启动app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '净智同心创意APP设计',
      theme: GlobalService.to.isDarkModel ? AppTheme.dark : AppTheme.light,
      home: const MyHomePage(title: '首页'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Obx(
              () => Container(
            color: GlobalService.to.isDarkModel
                ? Color(0xFF2F2E33) // 黑暗模式下的背景颜色
                : Colors.white,  // 亮模式下的背景颜色
            child: ListView(
              padding: EdgeInsets.zero,
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
                      Spacer(),
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
                // 在这里添加更多的 ListTile 或其他内容
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
                ))),
        title: Text(''),
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
                  () => Image.network(
                    GlobalService.to.isDarkModel
                        ? 'https://cdn.luogu.com.cn/upload/image_hosting/6pmuruan.png'
                        : 'https://cdn.luogu.com.cn/upload/image_hosting/o5dkrkgs.png',
                    fit: BoxFit.cover, // 图片覆盖整个区域
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
