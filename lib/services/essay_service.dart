import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:image_picker/image_picker.dart';

class EssayService {
  Future<String> postEssayRequest(String endpoint, String content) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.baseUrl + endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Access-Control-Allow-Origin': '*',
              'Connection': 'keep-alive',
            },
            body: jsonEncode({'content': content}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw Exception('请求超时'),
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['data']['content'] ?? '无内容';
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('网络连接失败，请检查网络设置或服务器地址');
      }
      throw Exception('错误: $e');
    }
  }

  Future<String> writeEssay(String content) =>
      postEssayRequest(ApiConfig.essayWrite, content);

  Future<String> getTemplate(String content) =>
      postEssayRequest(ApiConfig.essayTemplate, content);

  Future<String> continueEssay(String content) =>
      postEssayRequest(ApiConfig.essayContinue, content);

  Future<String> correctEssay(String content) =>
      postEssayRequest(ApiConfig.essayCorrect, content);

  Future<String> reviewEssay(String content) =>
      postEssayRequest(ApiConfig.essayReview, content);

  Future<String> uploadImage(XFile image) async {
    try {
      // 读取文件内容
      final bytes = await image.readAsBytes();
      final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.fileUpload);

      // 创建 multipart 请求
      var request = http.MultipartRequest('POST', uri);

      // 添加文件
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: image.name,
        ),
      );

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['file_name'];
      } else {
        throw Exception('上传失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('上传错误: $e');
    }
  }

  Future<String> recognizeImage(String fileName) async {
    try {
      final imageUrl =
          '${ApiConfig.baseUrl}${ApiConfig.fileDownload}/$fileName';
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.imageRecognition}').replace(
          queryParameters: {
            'image_url': imageUrl,
            'question': '识别图片的文字,只显示图片文本框的主要内容，不显示其他无关信息',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['data']['content'] ?? '无法识别文字';
      } else {
        throw Exception('识别失败: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('识别错误: $e');
    }
  }
}
