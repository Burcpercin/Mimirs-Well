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
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryGold,
              child: Icon(Icons.auto_awesome, color: AppTheme.background, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.userBubble : AppTheme.skaldBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(24),
                ),
                border: isUser 
                    ? null 
                    : Border.all(color: AppTheme.primaryGold.withOpacity(0.6), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: isUser ? AppTheme.userBubble.withOpacity(0.3) : AppTheme.primaryGold.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                message['text']!,
                style: TextStyle(
                  color: isUser ? AppTheme.textPrimary : AppTheme.primaryGold,
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: 0.3,
                  fontStyle: isUser ? FontStyle.normal : FontStyle.italic,
                  fontWeight: isUser ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.userBubble,
              child: Icon(Icons.person, color: Colors.white70, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatController controller) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 24.0),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: const Border(top: BorderSide(color: AppTheme.skaldBubble, width: 2)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: AppTheme.skaldBubble, width: 1.5),
                ),
                child: TextField(
                  controller: controller.textController,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => controller.sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Düşüncelerini rünlere dök...",
                    hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.4), fontStyle: FontStyle.italic),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => controller.sendMessage(),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGold, Color(0xFFB8860B)], // Altından koyu altına geçiş
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: AppTheme.background, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}