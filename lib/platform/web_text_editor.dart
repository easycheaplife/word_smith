import 'dart:html';
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class WebTextEditor {
  static Future<String?> showEditDialog(
      BuildContext context, String initialText) async {
    final element = TextAreaElement()
      ..value = initialText
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.padding = '8px'
      ..style.border = '1px solid #ccc'
      ..style.borderRadius = '4px'
      ..style.resize = 'none'
      ..style.outline = 'none'
      ..spellcheck = false;

    final viewId = 'textarea-${DateTime.now().millisecondsSinceEpoch}';
    ui.platformViewRegistry.registerViewFactory(viewId, (int _) => element);

    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 800,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('编辑内容',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: HtmlElementView(viewType: viewId),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context, element.value),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
