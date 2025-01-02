import 'package:flutter/material.dart';

abstract class TextInput {
  static Future<String?> showTextEditDialog(
      BuildContext context, String initialText) async {
    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      return _showMobileDialog(context, initialText);
    } else {
      return _showWebDialog(context, initialText);
    }
  }

  static Future<String?> _showMobileDialog(
      BuildContext context, String initialText) async {
    final controller = TextEditingController(text: initialText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑内容'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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

  static Future<String?> _showWebDialog(
      BuildContext context, String initialText) async {
    final controller = TextEditingController(text: initialText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑内容'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
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
