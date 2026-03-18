import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/controllers/app_locale_controller.dart';
import '../../../../app/localization/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../chat/application/chat_controller.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeController = AppLocaleScope.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SegmentedButton<Locale>(
          showSelectedIcon: false,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.textPrimary;
              }
              return AppColors.textSecondary;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.accentBlue.withValues(alpha: 0.18);
              }
              return Colors.transparent;
            }),
            side: const WidgetStatePropertyAll(BorderSide.none),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          segments: [
            ButtonSegment<Locale>(
              value: const Locale('sk'),
              label: Text(l10n.languageOptionSk),
            ),
            ButtonSegment<Locale>(
              value: const Locale('en'),
              label: Text(l10n.languageOptionEn),
            ),
          ],
          selected: <Locale>{localeController.locale},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) {
              return;
            }
            localeController.updateLocale(selection.first);
          },
        ),
      ),
    );
  }
}

class DesktopChatOverlay extends StatelessWidget {
  const DesktopChatOverlay({
    super.key,
    required this.chatControllerFactory,
  });

  final ChatController Function() chatControllerFactory;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < AppBreakpoints.desktopChat) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 22, bottom: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ChatPanel(
            controllerFactory: chatControllerFactory,
            width: 340,
            height: 420,
          ),
        ),
      ),
    );
  }
}

class MobileChatLauncher extends StatelessWidget {
  const MobileChatLauncher({
    super.key,
    required this.isOpen,
    required this.chatControllerFactory,
    required this.onToggle,
    required this.onClose,
  });

  final bool isOpen;
  final ChatController Function() chatControllerFactory;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final chatHeight = math.min(mediaQuery.size.height * 0.72, 520.0);

    return Stack(
      children: [
        if (isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.28),
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          left: 12,
          right: 12,
          bottom: isOpen ? keyboardInset + safeBottom + 82 : -(chatHeight + 60),
          child: IgnorePointer(
            ignoring: !isOpen,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isOpen ? 1 : 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.36),
                      blurRadius: 30,
                      spreadRadius: -6,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ChatPanel(
                  controllerFactory: chatControllerFactory,
                  height: chatHeight,
                  onClose: onClose,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 18,
          bottom: keyboardInset + safeBottom + 18,
          child: FloatingActionButton.extended(
            onPressed: onToggle,
            backgroundColor: AppColors.accentBlue,
            foregroundColor: AppColors.textPrimary,
            icon: Icon(
              isOpen ? Icons.close_rounded : Icons.chat_bubble_rounded,
            ),
            label: Text(
              isOpen ? l10n.chatLauncherClose : l10n.chatLauncherOpen,
            ),
          ),
        ),
      ],
    );
  }
}
