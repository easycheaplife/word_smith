
# 作文助手（word_smith）

AI 智能写作辅助工具，支持作文生成、续写、纠错、点评、模板获取、图片识别文字等功能。

## 主要功能

- 智能写作：根据输入内容生成作文
- 作文续写：对已有作文进行智能续写
- 作文纠错：对作文内容进行语法和表达纠错
- 作文点评：对作文进行智能点评
- 模板获取：获取作文模板
- 图片识别：上传图片并识别图片中的文字
- 历史记录：自动保存每次写作、识别等操作的历史，便于查阅

## 安装与运行

1. **环境准备**
   - Flutter SDK >= 3.6.0
   - Dart >= 3.6.0
   - Android/iOS/Web/Mac/Windows/Linux 设备

2. **依赖安装**
   ```bash
   flutter pub get
   ```

3. **运行项目**
   ```bash
   flutter run
   ```

## 主要依赖

- [http](https://pub.dev/packages/http)
- [image_picker](https://pub.dev/packages/image_picker)
- [intl](https://pub.dev/packages/intl)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

## API 接口说明

所有接口基地址：`http://127.0.0.1:80`

| 功能         | 路径                        | 说明           |
| ------------ | --------------------------- | -------------- |
| 作文写作     | /api/essay/write            | 智能生成作文   |
| 作文模板     | /api/essay/template         | 获取作文模板   |
| 作文续写     | /api/essay/continue         | 智能续写作文   |
| 作文纠错     | /api/essay/correct          | 作文纠错       |
| 作文点评     | /api/essay/review           | 作文点评       |
| 文件上传     | /api/file/upload            | 上传图片文件   |
| 文件下载     | /api/file/download          | 下载图片文件   |
| 图片识别     | /api/image-recognition      | 识别图片文字   |

## 目录结构简介

- `lib/main.dart`：应用入口
- `lib/services/essay_service.dart`：作文相关服务与 API 调用
- `lib/pages/history_page.dart`：历史记录页面
- `lib/config/`：配置信息（API、字符串、示例等）
- `lib/models/essay_history.dart`：历史记录数据模型

## 贡献

欢迎提交 issue 和 PR 参与项目改进。

## License

MIT
