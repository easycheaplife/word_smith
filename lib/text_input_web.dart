import 'dart:html';
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

Future<String?> showTextEditDialog(
    BuildContext context, String initialText) async {
  final divElement = DivElement()
    ..contentEditable = 'true'
    ..innerText = initialText
    ..style.width = '100%'
    ..style.height = '200px'
    ..style.padding = '8px'
    ..style.border = '1px solid #ccc'
    ..style.borderRadius = '4px'
    ..style.overflow = 'auto'
    ..style.outline = 'none'
    ..style.whiteSpace = 'pre-wrap';

  final viewId = 'editable-div-${DateTime.now().millisecondsSinceEpoch}';
  ui.platformViewRegistry.registerViewFactory(viewId, (int _) => divElement);

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('编辑内容'),
      content: SizedBox(
        width: double.maxFinite,
        height: 200,
        child: HtmlElementView(viewType: viewId),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, divElement.innerText),
          child: const Text('确定'),
        ),
      ],
    ),
  );
  return result;
}
