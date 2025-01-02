import 'package:flutter/material.dart';
import 'services/essay_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '作文助手',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EssayHomePage(),
    );
  }
}

class EssayHomePage extends StatefulWidget {
  const EssayHomePage({super.key});

  @override
  State<EssayHomePage> createState() => _EssayHomePageState();
}

class _EssayHomePageState extends State<EssayHomePage> {
  final TextEditingController _contentController = TextEditingController();
  final EssayService _essayService = EssayService();
  String _result = '';
  bool _isLoading = false;
  String _selectedFunction = 'write'; // 默认选择写作文

  // 定义功能选项
  final Map<String, Map<String, dynamic>> _functionOptions = {
    'write': {
      'label': '写作文',
      'example': '请写一篇关于环境保护的作文，主题是垃圾分类与环保',
      'function': (EssayService service) => service.writeEssay,
    },
    'template': {
      'label': '作文模板',
      'example': '请提供一个关于科技发展利弊的议论文模板',
      'function': (EssayService service) => service.getTemplate,
    },
    'continue': {
      'label': '作文续写',
      'example': '那天下午，我在书房里写作业，突然听到窗外传来一阵奇怪的声音...',
      'function': (EssayService service) => service.continueEssay,
    },
    'correct': {
      'label': '作文纠错',
      'example': '今天，我和同学去公园游玩。一进公园，映入眼帘的是一片花海，有红的、黄的、蓝的，非常的漂亮。我们玩的很开心。',
      'function': (EssayService service) => service.correctEssay,
    },
    'review': {
      'label': '作文点评',
      'example':
          '春天来了，小草从土里钻出来，伸展着嫩绿的身躯。树枝上冒出了新芽，像一个个可爱的小脑袋。小鸟在枝头欢快地歌唱，蝴蝶在花丛中翩翩起舞。春天真是一个充满生机的季节。',
      'function': (EssayService service) => service.reviewEssay,
    },
  };

  @override
  void initState() {
    super.initState();
    // 设置默认示例文字
    _contentController.text = _functionOptions[_selectedFunction]!['example'];
  }

  Future<void> _processEssayRequest() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final apiCall =
          _functionOptions[_selectedFunction]!['function'](_essayService);
      final response = await apiCall(_contentController.text);
      setState(() {
        _result = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作文助手'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 下拉选择框
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFunction,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: _functionOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value['label']),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedFunction = value;
                        _contentController.text =
                            _functionOptions[value]!['example'];
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 输入框
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: '请输入内容...',
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 提交按钮
            ElevatedButton(
              onPressed: _processEssayRequest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('提交'),
            ),
            const SizedBox(height: 16),
            // 结果显示区域
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(_result),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
