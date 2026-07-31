import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'core/app_theme.dart';
import 'ui/chat_screen.dart';

void main() {
  runApp(const SagaMentorApp());
}

class SagaMentorApp extends StatelessWidget {
  const SagaMentorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SagaMentor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ChatScreen(),
    );
  }
}