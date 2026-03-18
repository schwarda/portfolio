import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../domain/chat_models.dart';
import '../domain/chat_repository.dart';

class HttpChatRepository implements ChatRepository {
  const HttpChatRepository();

  static const _configuredChatApiUrl = String.fromEnvironment(
    'CHAT_API_URL',
    defaultValue: '',
  );
  static const _configuredTurnstileSiteKey = String.fromEnvironment(
    'TURNSTILE_SITE_KEY',
    defaultValue: '',
  );

  String get _chatApiUrl {
    final configuredUrl = _configuredChatApiUrl.trim();
    if (configuredUrl.isNotEmpty) {
      return configuredUrl;
    }

    final host = Uri.base.host.toLowerCase();
    if (host == 'localhost' || host == '127.0.0.1') {
      return 'http://127.0.0.1:8787/api/chat';
    }

    return '/api/chat';
  }

  @override
  bool get isLocalHost {
    final host = Uri.base.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1';
  }

  @override
  bool get isConfigured => _chatApiUrl.trim().isNotEmpty;

  @override
  bool get requiresUnlock => !isLocalHost;

  @override
  bool get isUnlockConfigured =>
      !requiresUnlock || turnstileSiteKey.trim().isNotEmpty;

  @override
  String get turnstileSiteKey => _configuredTurnstileSiteKey.trim();

  Uri _requireChatUri() {
    final uri = Uri.tryParse(_chatApiUrl);
    if (uri == null) {
      throw const ChatFailure(type: ChatFailureType.invalidApiUrl);
    }
    return uri;
  }

  Uri _unlockUri(Locale locale) {
    final chatUri = _requireChatUri();
    return chatUri.replace(
      path: '${chatUri.path}/unlock',
      queryParameters: <String, String>{
        ...chatUri.queryParameters,
        'locale': locale.languageCode,
      },
    );
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    final responseText = utf8.decode(response.bodyBytes);
    final vercelMitigation = response.headers['x-vercel-mitigated'];
    final looksLikeVercelChallenge = vercelMitigation == 'challenge' ||
        responseText.contains('Vercel Security Checkpoint') ||
        responseText.contains('x-vercel-challenge-token');

    if (looksLikeVercelChallenge) {
      throw const ChatFailure(type: ChatFailureType.firewallBlocked);
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(responseText);
    } on FormatException {
      if (response.statusCode >= 400) {
        throw ChatFailure(
          type: ChatFailureType.backendReturnedNonJsonError,
          statusCode: response.statusCode,
        );
      }
      throw const ChatFailure(type: ChatFailureType.backendInvalidJson);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ChatFailure(type: ChatFailureType.backendInvalidResponse);
    }

    if (response.statusCode >= 400) {
      final error = decoded['error'];
      if (error is String && error.trim().isNotEmpty) {
        throw ChatFailure.custom(error.trim());
      }
      throw ChatFailure(
        type: ChatFailureType.backendProxyError,
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  @override
  Future<bool> unlockStatus({
    required Locale locale,
  }) async {
    try {
      final response = await http
          .get(_unlockUri(locale))
          .timeout(const Duration(seconds: 15));
      final decoded = _decodeJsonResponse(response);
      return decoded['unlocked'] == true;
    } on http.ClientException {
      throw ChatFailure(
        type: ChatFailureType.backendConnectionError,
        uri: _unlockUri(locale).toString(),
      );
    }
  }

  @override
  Future<void> unlockChat({
    required String turnstileToken,
    required Locale locale,
  }) async {
    final response = await http
        .post(
          _unlockUri(locale),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'turnstileToken': turnstileToken,
            'locale': locale.languageCode,
          }),
        )
        .timeout(const Duration(seconds: 30));

    _decodeJsonResponse(response);
  }

  @override
  Future<String> reply({
    required List<ChatMessage> messages,
    required String profileContext,
    required Locale locale,
  }) async {
    if (!isConfigured) {
      throw const ChatFailure(type: ChatFailureType.missingApiUrl);
    }

    final uri = _requireChatUri();
    final payloadMessages = messages
        .where((message) =>
            !message.isTyping && !message.isError && message.text.isNotEmpty)
        .map((message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'text': message.text,
            })
        .toList();

    late final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'messages': payloadMessages,
              'profileContext': profileContext,
              'locale': locale.languageCode,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } on http.ClientException {
      throw ChatFailure(
        type: ChatFailureType.backendConnectionError,
        uri: uri.toString(),
      );
    }

    final decoded = _decodeJsonResponse(response);
    final reply = decoded['reply'];
    if (reply is String && reply.trim().isNotEmpty) {
      return reply.trim();
    }

    throw const ChatFailure(type: ChatFailureType.backendMissingReply);
  }
}
