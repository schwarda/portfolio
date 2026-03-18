import 'package:flutter/widgets.dart';

import 'chat_models.dart';

abstract interface class ChatRepository {
  bool get isConfigured;

  bool get isLocalHost;

  bool get requiresUnlock;

  bool get isUnlockConfigured;

  String get turnstileSiteKey;

  Future<bool> unlockStatus({
    required Locale locale,
  });

  Future<void> unlockChat({
    required String turnstileToken,
    required Locale locale,
  });

  Future<String> reply({
    required List<ChatMessage> messages,
    required String profileContext,
    required Locale locale,
  });
}
