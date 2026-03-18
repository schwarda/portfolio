enum ChatAuthor {
  user,
  assistant,
}

enum ChatMessageType {
  regular,
  typing,
  error,
}

class ChatMessage {
  const ChatMessage._({
    required this.text,
    required this.author,
    required this.type,
    this.isLocalizedSeed = false,
  });

  factory ChatMessage.user(String text) {
    return ChatMessage._(
      text: text,
      author: ChatAuthor.user,
      type: ChatMessageType.regular,
    );
  }

  factory ChatMessage.assistant(
    String text, {
    bool isLocalizedSeed = false,
  }) {
    return ChatMessage._(
      text: text,
      author: ChatAuthor.assistant,
      type: ChatMessageType.regular,
      isLocalizedSeed: isLocalizedSeed,
    );
  }

  factory ChatMessage.typing(String text) {
    return ChatMessage._(
      text: text,
      author: ChatAuthor.assistant,
      type: ChatMessageType.typing,
    );
  }

  factory ChatMessage.error(
    String text, {
    bool isLocalizedSeed = false,
  }) {
    return ChatMessage._(
      text: text,
      author: ChatAuthor.assistant,
      type: ChatMessageType.error,
      isLocalizedSeed: isLocalizedSeed,
    );
  }

  final String text;
  final ChatAuthor author;
  final ChatMessageType type;
  final bool isLocalizedSeed;

  bool get isUser => author == ChatAuthor.user;

  bool get isTyping => type == ChatMessageType.typing;

  bool get isError => type == ChatMessageType.error;
}

enum ChatFailureType {
  missingApiUrl,
  invalidApiUrl,
  firewallBlocked,
  backendReturnedNonJsonError,
  backendInvalidJson,
  backendInvalidResponse,
  backendProxyError,
  backendConnectionError,
  backendMissingReply,
  custom,
}

class ChatFailure implements Exception {
  const ChatFailure({
    required this.type,
    this.backendMessage,
    this.statusCode,
    this.uri,
  });

  const ChatFailure.custom(String backendMessage)
      : this(
          type: ChatFailureType.custom,
          backendMessage: backendMessage,
        );

  final ChatFailureType type;
  final String? backendMessage;
  final int? statusCode;
  final String? uri;
}
