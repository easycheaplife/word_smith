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

  Future<void> _processEssayRequest(
      Future<String> Function(String) apiCall) async {
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
                  hintText: '请输入作文内容...',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _processEssayRequest(_essayService.writeEssay),
                  child: const Text('写作文'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _processEssayRequest(_essayService.getTemplate),
                  child: const Text('作文模板'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _processEssayRequest(_essayService.continueEssay),
                  child: const Text('作文续写'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _processEssayRequest(_essayService.correctEssay),
                  child: const Text('作文纠错'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _processEssayRequest(_essayService.reviewEssay),
                  child: const Text('作文点评'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
