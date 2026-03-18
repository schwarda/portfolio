import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../turnstile/turnstile.dart';
import '../domain/chat_models.dart';
import '../domain/chat_repository.dart';
import '../domain/profile_context_builder.dart';

class ChatController extends ChangeNotifier {
  ChatController({
    required ChatRepository chatRepository,
    required ProfileContextBuilder profileContextBuilder,
    required this.turnstileController,
  })  : _chatRepository = chatRepository,
        _profileContextBuilder = profileContextBuilder,
        _isChatUnlocked = !chatRepository.requiresUnlock {
    if (_chatRepository.requiresUnlock) {
      turnstileController.addListener(_handleTurnstileStateChanged);
    }
  }

  final ChatRepository _chatRepository;
  final ProfileContextBuilder _profileContextBuilder;
  final List<ChatMessage> _messages = <ChatMessage>[];

  AppLocalizations? _localizations;
  bool _isDisposed = false;
  bool _isSending = false;
  bool _isUnlocking = false;
  bool _hasInitializedMessages = false;
  bool _isChatUnlocked;
  String? _localeCode;

  final TurnstileController turnstileController;

  UnmodifiableListView<ChatMessage> get messages =>
      UnmodifiableListView(_messages);

  bool get isSending => _isSending;

  bool get isUnlocking => _isUnlocking;

  bool get isChatUnlocked => _isChatUnlocked;

  bool get canCallApi => _chatRepository.isConfigured;

  bool get requiresUnlock => _chatRepository.requiresUnlock;

  bool get isUnlockConfigured => _chatRepository.isUnlockConfigured;

  bool get canUseChat => canCallApi && (!requiresUnlock || _isChatUnlocked);

  void bindLocalizations(AppLocalizations localizations) {
    _localizations = localizations;
    final localeCode = localizations.locale.languageCode;
    final localeChanged = _localeCode != null && _localeCode != localeCode;

    if (_localeCode != localeCode) {
      _localeCode = localeCode;
      turnstileController.updateLocaleCode(localeCode);
      if (localeChanged) {
        _refreshSeedMessagesIfPossible(localizations);
      }
    }

    if (_hasInitializedMessages) {
      return;
    }

    _hasInitializedMessages = true;
    _messages.addAll(_buildSeedMessages(localizations));

    if (requiresUnlock && isUnlockConfigured) {
      unawaited(_restoreUnlockState(localizations.locale));
    }
  }

  List<ChatMessage> _buildSeedMessages(AppLocalizations l10n) {
    final seedMessages = <ChatMessage>[
      ChatMessage.assistant(
        l10n.chatIntroLineOne,
        isLocalizedSeed: true,
      ),
      ChatMessage.assistant(
        l10n.chatIntroLineTwo,
        isLocalizedSeed: true,
      ),
    ];

    if (!canCallApi) {
      seedMessages.add(
        ChatMessage.error(
          l10n.chatNeedsBackendEndpoint,
          isLocalizedSeed: true,
        ),
      );
    }

    if (requiresUnlock && !isUnlockConfigured) {
      seedMessages.add(
        ChatMessage.error(
          l10n.chatProtectionMisconfigured,
          isLocalizedSeed: true,
        ),
      );
    }

    return seedMessages;
  }

  void _refreshSeedMessagesIfPossible(AppLocalizations l10n) {
    final canRefresh = _messages.isNotEmpty &&
        _messages.every((message) => message.isLocalizedSeed);
    if (!canRefresh) {
      return;
    }

    _messages
      ..clear()
      ..addAll(_buildSeedMessages(l10n));
  }

  Future<void> _restoreUnlockState(Locale locale) async {
    try {
      final unlocked = await _chatRepository.unlockStatus(locale: locale);
      if (_isDisposed || _localeCode != locale.languageCode) {
        return;
      }

      _isChatUnlocked = unlocked;
      notifyListeners();
    } catch (_) {
      // Keep the chat locked until the user retries.
    }
  }

  void startUnlockFlow() {
    final localizations = _localizations;
    if (localizations == null || _isUnlocking || _isChatUnlocked) {
      return;
    }

    if (!isUnlockConfigured) {
      _appendErrorMessage(localizations.chatProtectionMisconfigured);
      return;
    }

    turnstileController.ensureRendered();
    notifyListeners();
  }

  void _handleTurnstileStateChanged() {
    if (_isDisposed) {
      return;
    }

    notifyListeners();

    if (!requiresUnlock || _isChatUnlocked || _isUnlocking) {
      return;
    }

    final token = turnstileController.token?.trim() ?? '';
    if (token.isEmpty) {
      return;
    }

    unawaited(_completeUnlock(token));
  }

  Future<void> _completeUnlock(String turnstileToken) async {
    final localizations = _localizations;
    if (localizations == null || _isUnlocking || _isChatUnlocked) {
      return;
    }

    _isUnlocking = true;
    notifyListeners();

    try {
      await _chatRepository.unlockChat(
        turnstileToken: turnstileToken,
        locale: localizations.locale,
      );
      if (_isDisposed) {
        return;
      }

      _isChatUnlocked = true;
    } on ChatFailure catch (failure) {
      if (_isDisposed) {
        return;
      }
      _appendErrorMessage(
        _messageForFailure(failure, localizations),
        shouldNotify: false,
      );
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      _appendErrorMessage(
        localizations.chatVerificationFailed,
        shouldNotify: false,
      );
    } finally {
      if (!_isDisposed) {
        _isUnlocking = false;
        turnstileController.close();
        turnstileController.reset();
        notifyListeners();
      }
    }
  }

  Future<void> sendMessage(String rawText) async {
    final localizations = _localizations;
    final text = rawText.trim();
    if (localizations == null || text.isEmpty || _isSending) {
      return;
    }

    if (!canCallApi) {
      _appendErrorMessage(localizations.chatMissingApiUrl);
      return;
    }

    if (requiresUnlock && !_isChatUnlocked) {
      _appendErrorMessage(localizations.chatUnlockFirstError);
      return;
    }

    _messages
      ..add(ChatMessage.user(text))
      ..add(ChatMessage.typing(localizations.chatTypingMessage));
    _isSending = true;
    notifyListeners();

    try {
      final reply = await _chatRepository.reply(
        messages: _messages.where((message) => !message.isTyping).toList(),
        profileContext: _profileContext(localizations),
        locale: localizations.locale,
      );
      if (_isDisposed) {
        return;
      }
      _replaceTypingMessage(ChatMessage.assistant(reply));
    } on TimeoutException {
      if (_isDisposed) {
        return;
      }
      _replaceTypingMessage(
        ChatMessage.error(localizations.chatProviderTimeout),
      );
    } on ChatFailure catch (failure) {
      if (_isDisposed) {
        return;
      }
      _replaceTypingMessage(
        ChatMessage.error(_messageForFailure(failure, localizations)),
      );
    } catch (_) {
      if (_isDisposed) {
        return;
      }
      _replaceTypingMessage(
        ChatMessage.error(localizations.chatUnexpectedError),
      );
    } finally {
      if (!_isDisposed) {
        _isSending = false;
        notifyListeners();
      }
    }
  }

  String unlockHelperText(AppLocalizations l10n) {
    final statusMessage = turnstileController.statusMessage;
    return statusMessage ??
        (_isChatUnlocked
            ? l10n.chatUnlockedForSession
            : _isUnlocking
                ? l10n.chatFinishingVerification
                : l10n.chatUnlockBeforeFirstMessage);
  }

  void _replaceTypingMessage(ChatMessage replacement) {
    _messages.removeWhere((message) => message.isTyping);
    _messages.add(replacement);
  }

  String _profileContext(AppLocalizations l10n) {
    return _profileContextBuilder.build(
      locale: l10n.locale,
      labels: ProfileContextLabels(
        name: l10n.profileContextNameLabel,
        role: l10n.profileContextRoleLabel,
        location: l10n.profileContextLocationLabel,
        bio: l10n.profileContextBioLabel,
        contact: l10n.profileContextContactLabel,
        stats: l10n.profileContextStatsLabel,
        internalNotes: l10n.profileContextInternalNotesLabel,
      ),
    );
  }

  String _messageForFailure(
    ChatFailure failure,
    AppLocalizations localizations,
  ) {
    if ((failure.backendMessage ?? '').trim().isNotEmpty) {
      return failure.backendMessage!.trim();
    }

    switch (failure.type) {
      case ChatFailureType.missingApiUrl:
        return localizations.chatMissingApiUrl;
      case ChatFailureType.invalidApiUrl:
        return localizations.chatApiUrlInvalid;
      case ChatFailureType.firewallBlocked:
        return localizations.chatFirewallBlocked;
      case ChatFailureType.backendReturnedNonJsonError:
        return localizations.chatBackendReturnedNonJsonError(
          failure.statusCode ?? 500,
        );
      case ChatFailureType.backendInvalidJson:
        return localizations.chatBackendInvalidJson;
      case ChatFailureType.backendInvalidResponse:
        return localizations.chatBackendInvalidResponse;
      case ChatFailureType.backendProxyError:
        return localizations.chatBackendProxyError(
          failure.statusCode ?? 500,
        );
      case ChatFailureType.backendConnectionError:
        return localizations.chatBackendConnectionError(
          failure.uri ?? '',
        );
      case ChatFailureType.backendMissingReply:
        return localizations.chatBackendMissingReply;
      case ChatFailureType.custom:
        return localizations.chatUnexpectedError;
    }
  }

  void _appendErrorMessage(
    String text, {
    bool shouldNotify = true,
  }) {
    _messages.add(ChatMessage.error(text));
    if (shouldNotify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    turnstileController.removeListener(_handleTurnstileStateChanged);
    turnstileController.dispose();
    super.dispose();
  }
}
