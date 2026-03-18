import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../application/chat_controller.dart';
import '../../domain/chat_models.dart';

class ChatPanel extends StatefulWidget {
  const ChatPanel({
    super.key,
    required this.controllerFactory,
    this.width = double.infinity,
    this.height = 360,
    this.onClose,
  });

  final ChatController Function() controllerFactory;
  final double width;
  final double height;
  final VoidCallback? onClose;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  late final ChatController _controller = widget.controllerFactory();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _lastMessageSignature = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.bindLocalizations(AppLocalizations.of(context));
    _lastMessageSignature = _messageSignature();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    final nextSignature = _messageSignature();
    if (nextSignature == _lastMessageSignature) {
      return;
    }

    _lastMessageSignature = nextSignature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  String _messageSignature() {
    if (_controller.messages.isEmpty) {
      return '0';
    }

    final message = _controller.messages.last;
    return [
      _controller.messages.length,
      message.text,
      message.type.name,
      message.isLocalizedSeed,
    ].join(':');
  }

  void _handleSendPressed() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }

    _inputController.clear();
    unawaited(_controller.sendMessage(text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.stroke),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentTeal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.chatPanelTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        _controller.isSending
                            ? l10n.chatStatusSending
                            : l10n.chatStatusOnline,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                      if (widget.onClose != null) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          visualDensity: VisualDensity.compact,
                          tooltip: l10n.chatCloseButton,
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    itemCount: _controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = _controller.messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.stroke),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_controller.requiresUnlock) ...[
                        _UnlockStatusBanner(
                          controller: _controller,
                          onUnlockPressed: _controller.startUnlockFlow,
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              onSubmitted: _controller.canUseChat &&
                                      !_controller.isSending
                                  ? (_) => _handleSendPressed()
                                  : null,
                              enabled: _controller.canUseChat &&
                                  !_controller.isSending,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: !_controller.canCallApi
                                    ? l10n.chatInputHintMissingApi
                                    : _controller.requiresUnlock &&
                                            !_controller.isChatUnlocked
                                        ? l10n.chatInputHintUnlockFirst
                                        : l10n.chatInputHint,
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceStrong,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed:
                                _controller.canUseChat && !_controller.isSending
                                    ? _handleSendPressed
                                    : null,
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.accentBlue.withValues(alpha: 0.22)
              : message.isError
                  ? const Color(0x33FF6B6B)
                  : AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        child: message.isTyping
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                ],
              )
            : Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
      ),
    );
  }
}

class _UnlockStatusBanner extends StatelessWidget {
  const _UnlockStatusBanner({
    required this.controller,
    required this.onUnlockPressed,
  });

  final ChatController controller;
  final VoidCallback onUnlockPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusMessage = controller.turnstileController.statusMessage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Icon(
            controller.isChatUnlocked
                ? Icons.lock_open_rounded
                : Icons.shield_outlined,
            size: 16,
            color: controller.isChatUnlocked
                ? AppColors.accentTeal
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.unlockHelperText(l10n),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusMessage != null
                        ? const Color(0xFFFFB4AB)
                        : AppColors.textSecondary,
                  ),
            ),
          ),
          if (!controller.isChatUnlocked) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: controller.isUnlocking ? null : onUnlockPressed,
              child: Text(
                controller.isUnlocking
                    ? l10n.chatUnlockWaiting
                    : l10n.chatUnlockButton,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
