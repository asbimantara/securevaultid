import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class ClipboardService {
  static Future<void> copyToClipboard(
    String text, {
    Duration clearAfter = const Duration(seconds: 30),
  }) async {
    await Clipboard.setData(ClipboardData(text: text));

    // Clear clipboard after specified duration
    Future.delayed(clearAfter, () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  static Future<void> clearClipboard() async {
    await Clipboard.setData(const ClipboardData(text: ''));
  }
}
