import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '    在这个星球上，每一片落叶、每一滴清水、每一缕清新的空气，都是大自然赋予我们的宝贵礼物。'
                    '然而，随着工业化的进程，这些礼物正面临着前所未有的威胁。为了守护这份珍贵的遗产，我们推出了一款名为“净智同心”的手机应用，'
                    '它不仅是一个工具，更是一份对地球的深情告白。\n\n'
                    '    “净智同心”的核心理念是“智能环保，从我做起”。它通过三个精心设计的功能，引导用户参与到环保行动中来，'
                    '共同构建一个更加绿色、更加和谐的世界。\n\n'
                    '    首先，是“碳索世界”功能。它如同一位智慧的向导，在你规划每一次出行时，都会为你计算出不同出行方式的碳足迹。'
                    '每一次选择步行、骑行或乘坐公共交通，都是对地球的一次温柔呵护。我们相信，通过这样的方式，可以激发每个人内心深处的环保意识，'
                    '让绿色出行成为我们共同的选择。\n\n'
                    '    接着，是“智能分类”功能。在这个功能中，我们运用了先进的图像识别技术，帮助用户轻松识别垃圾类型，正确进行垃圾分类。'
                    '这不仅让垃圾分类变得简单有趣，更重要的是，它在潜移默化中培养了用户的环保习惯。每一次正确的分类，都是对地球资源的一次珍惜，'
                    '也是对未来的一份承诺。\n\n'
                    '    最后，是“答题中心”。这里是一个知识的宝库，也是一个环保意识的培养基地。用户可以通过回答环保知识选择题，来测试和提升自己的环保知识。'
                    '答对题目不仅能获得积分奖励，更重要的是，它让环保知识变得更加生动有趣。我们相信，知识的传递和积累，是推动社会进步的重要力量。\n\n'
                    '    “净智同心”不仅仅是一个应用，它是一种生活态度，一种对未来的承诺。我们希望通过这款应用，让环保成为每个人生活的一部分，'
                    '让绿色成为我们共同的色彩。让我们一起，用科技的力量，守护我们美丽的地球家园，让净智同心，成为我们共同的行动。',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}