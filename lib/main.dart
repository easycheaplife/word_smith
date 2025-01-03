import 'package:flutter/material.dart';
import 'services/essay_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'platform/text_editor.dart';

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

  // 添加构建输入框的方法
  Widget _buildInputField() {
    if (kIsWeb) {
      // Web 平台使用固定高度的只读文本显示
      return Container(
        height: 150, // 固定高度
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              // 添加滚动支持
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Text(
                _contentController.text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickAndRecognizeImage,
                    tooltip: '从图片识别文字',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showEditDialog,
                    tooltip: '编辑文本',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 非 Web 平台使用固定高度的 TextField
      return Container(
        height: 150, // 固定高度
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            TextField(
              controller: _contentController,
              maxLines: null, // 允许无限行
              expands: true, // 填充可用空间
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(16, 40, 16, 16),
                border: InputBorder.none,
                hintText: '请输入内容或点击右上角图标识别图片文字...',
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickAndRecognizeImage,
                tooltip: '从图片识别文字',
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pickAndRecognizeImage() async {
    try {
      setState(() => _isLoading = true);

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final fileName = await _essayService.uploadImage(image);
        final recognizedText = await _essayService.recognizeImage(fileName);

        setState(() {
          _contentController.text = recognizedText;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('错误: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 添加编辑对话框方法
  Future<void> _showEditDialog() async {
    final result = await WebTextEditor.showEditDialog(
      context,
      _contentController.text,
    );

    if (result != null) {
      setState(() {
        _contentController.text = result;
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
            _buildInputField(), // 使用新的输入框构建方法
            const SizedBox(height: 16),
            // 提交按钮
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: _processEssayRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size.fromHeight(36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('提交'),
                ),
              ),
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
