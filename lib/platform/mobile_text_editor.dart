import 'package:flutter/material.dart';

class WebTextEditor {
  static Future<String?> showEditDialog(
      BuildContext context, String initialText) async {
    final controller = TextEditingController(text: initialText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑内容'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
