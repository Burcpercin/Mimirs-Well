import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String _baseUrl = 'http://localhost:3000'; 

  Future<String> askMimir(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ask-mimir'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['answer'] ?? 'Mimir sessiz kaldı...';
      } else {
        return 'Sular bulanık. Nornlar şu an meşgul (Hata Kodu: ${response.statusCode}).';
      }
    } catch (e) {
      print('API Error: $e'); 
      return 'Kuyuya ulaşamıyorum. Rüzgar çok sert esiyor. (Sunucu kapalı olabilir)';
    }
  }
}