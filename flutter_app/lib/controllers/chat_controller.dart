import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class ChatController extends GetxController {
  final ApiService _apiService = ApiService();
  
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var messages = <Map<String, String>>[
    {
      'role': 'skald',
      'text': 'Hoş geldin gezgin. Valhalla\'nın salonlarına giden yol çetindir. Bugün omuzlarında hangi dünyanın yükünü taşıyorsun? Anlat...'
    }
  ].obs;
  
  var isLoading = false.obs;

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add({'role': 'user', 'text': text});
    isLoading.value = true;
    textController.clear();
    _scrollToBottom();

    final answer = await _apiService.askMimir(text);

    messages.add({'role': 'skald', 'text': answer});
    isLoading.value = false;
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}