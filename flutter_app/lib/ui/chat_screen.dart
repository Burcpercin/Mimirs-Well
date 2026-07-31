import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_theme.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller'ı hafızaya alıyoruz
    final ChatController controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(title: const Text("MIMIR'S WELL")),
      body: Column(
        children: [
          Expanded(
            // Obx ile sadece listeyi dinliyoruz
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(controller.messages[index], context),
            )),
          ),
          
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: AppTheme.primaryGold),
              );
            }
            return const SizedBox.shrink();
          }),
          
          _buildInputArea(controller),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message, BuildContext context) {
    bool isUser = message['role'] == 'user';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.userBubble : AppTheme.skaldBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : AppTheme.primaryGold.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))
          ],
        ),
        child: Text(
          message['text']!,
          style: TextStyle(
            color: isUser ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 16,
            height: 1.4,
            fontStyle: isUser ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Düşüncelerini rünlere dök...",
                  hintStyle: TextStyle(color: AppTheme.textPrimary.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppTheme.skaldBubble,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryGold,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.background),
                onPressed: () => controller.sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}