import 'package:flutter/material.dart';
import 'services/essay_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'platform/text_editor.dart';
import 'config/essay_examples.dart';
import 'config/app_strings.dart';
import 'models/essay_history.dart';
import 'pages/history_page.dart';
import 'services/history_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
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

class _EssayHomePageState extends State<EssayHomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final EssayService _essayService = EssayService();
  String _result = '';
  bool _isLoading = false;
  String _selectedFunction = 'write'; // 默认选择写作文
  late TabController _tabController;
  List<EssayHistory> _histories = [];
  final HistoryService _historyService = HistoryService();

  // 定义功能选项
  final Map<String, Map<String, dynamic>> _functionOptions = {
    'write': {
      'label': EssayExamples.examples['write']!['label'],
      'example': EssayExamples.examples['write']!['example'],
      'function': (EssayService service) => service.writeEssay,
    },
    'template': {
      'label': EssayExamples.examples['template']!['label'],
      'example': EssayExamples.examples['template']!['example'],
      'function': (EssayService service) => service.getTemplate,
    },
    'continue': {
      'label': EssayExamples.examples['continue']!['label'],
      'example': EssayExamples.examples['continue']!['example'],
      'function': (EssayService service) => service.continueEssay,
    },
    'correct': {
      'label': EssayExamples.examples['correct']!['label'],
      'example': EssayExamples.examples['correct']!['example'],
      'function': (EssayService service) => service.correctEssay,
    },
    'review': {
      'label': EssayExamples.examples['review']!['label'],
      'example': EssayExamples.examples['review']!['example'],
      'function': (EssayService service) => service.reviewEssay,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistories();
    // 设置默认示例文字
    _contentController.text = _functionOptions[_selectedFunction]!['example'];
  }

  Future<void> _loadHistories() async {
    final loadedHistories = await _historyService.loadHistories();
    setState(() {
      _histories = loadedHistories;
    });
  }

  Future<void> _clearHistories() async {
    await _historyService.clearHistories();
    setState(() {
      _histories = [];
    });
  }

  Future<void> _processEssayRequest() async {
    if (_contentController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.emptyContentError)),
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
      if (!mounted) return;
      setState(() {
        _result = response;
        _histories.insert(
          0,
          EssayHistory(
            input: _contentController.text,
            output: response,
            timestamp: DateTime.now(),
            functionType: _functionOptions[_selectedFunction]!['label'],
          ),
        );
      });
      await _historyService.saveHistories(_histories);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorPrefix}$e')),
      );
    } finally {
      if (!mounted) return;
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
                    tooltip: AppStrings.imageRecognitionTooltip,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showEditDialog,
                    tooltip: AppStrings.editTextTooltip,
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
                hintText: AppStrings.inputHint,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: _pickAndRecognizeImage,
                tooltip: AppStrings.imageRecognitionTooltip,
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
        if (!mounted) return;
        setState(() {
          _contentController.text = recognizedText;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorPrefix}$e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        title: Text(AppStrings.appTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.writeTab),
            Tab(text: AppStrings.historyTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWriteTab(),
          HistoryPage(
            histories: _histories,
            onClearHistories: _clearHistories,
          ),
        ],
      ),
    );
  }

  Widget _buildWriteTab() {
    return Padding(
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
                      _result = ''; // 清空结果显示
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
                child: Text(AppStrings.submitButton),
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
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
