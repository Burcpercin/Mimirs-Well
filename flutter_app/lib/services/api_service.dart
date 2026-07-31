import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Emulator için 10.0.2.2 kullanıyoruz (localhost yerine)
  static const String _baseUrl = 'http://10.0.2.2:3000'; 

  Future<String> askMimir(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ask-mimir'),
        // Karakter setini utf-8 olarak başlıkta (header) açıkça belirtiyoruz
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        // TÜRKÇE KARAKTER ÇÖZÜMÜ: response.body yerine, ham baytları alıp UTF-8'e çeviriyoruz
        final data = json.decode(utf8.decode(response.bodyBytes));
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