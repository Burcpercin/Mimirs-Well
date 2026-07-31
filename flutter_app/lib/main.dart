import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http; // Sunucuya bağlanmak için gerekli

void main() {
  runApp(const SagaMentorApp());
}

class SagaMentorApp extends StatelessWidget {
  const SagaMentorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SagaMentor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101419),
        primaryColor: const Color(0xFF1E272E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Eskitilmiş Altın
          secondary: Color(0xFF2C3E50), // Derin Fiyort Mavisi
        ),
        fontFamily: 'Georgia', // Rünik hava için edebi bir font (standart olarak bulunur)
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Mesaj listesi
  final List<Map<String, String>> _messages = [
    {
      'role': 'skald',
      'text': 'Hoş geldin gezgin. Valhalla\'nın salonlarına giden yol çetindir. Bugün omuzlarında hangi dünyanın yükünü taşıyorsun? Anlat...'
    }
  ];
  
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      // DİKKAT: Bilgisayarda çalışan emülatörler için 'localhost' yerine özel bir IP (10.0.2.2) gerekir. 
      // Eğer Chrome'da (Web) test ediyorsan bu 'http://localhost:3000/ask-mimir' olmalıdır.
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/ask-mimir'), 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add({'role': 'skald', 'text': data['answer']});
        });
      } else {
         setState(() {
          _messages.add({'role': 'skald', 'text': 'Sular bulanık. Nornlar şu an meşgul (Hata Kodu: ${response.statusCode}).'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'skald', 'text': 'Kuyuya ulaşamıyorum. Rüzgar çok sert esiyor. (Sunucu kapalı olabilir)'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    bool isUser = message['role'] == 'user';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2C3E50) : const Color(0xFF1E272E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          message['text']!,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFFE0E0E0),
            fontSize: 16,
            height: 1.4,
            fontStyle: isUser ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MIMIR'S WELL",
          style: TextStyle(
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF101419),
        elevation: 2,
        shadowColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF151A21),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Düşüncelerini rünlere dök...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: const Color(0xFF1E272E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4AF37),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF101419)),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}