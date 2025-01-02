import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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
}
