import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_backdrop.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../chat/application/chat_controller.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';
import '../../application/portfolio_action_controller.dart';
import '../../domain/portfolio_content_repository.dart';
import '../controllers/portfolio_page_controller.dart';
import '../widgets/portfolio_sections.dart';
import '../widgets/portfolio_shell_widgets.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({
    super.key,
    required this.portfolioContentRepository,
    required this.portfolioActionController,
    required this.chatControllerFactory,
  });

  final PortfolioContentRepository portfolioContentRepository;
  final PortfolioActionController portfolioActionController;
  final ChatController Function() chatControllerFactory;

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  late final PortfolioPageController _pageController =
      PortfolioPageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _runPortfolioAction(
    Future<String?> Function(AppLocalizations l10n) action,
  ) async {
    final message = await action(AppLocalizations.of(context));
    if (!mounted || message == null) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEmail() {
    return _runPortfolioAction(widget.portfolioActionController.openEmail);
  }

  Future<void> _openExternalProfile(String url) {
    return _runPortfolioAction(
      (l10n) => widget.portfolioActionController.openExternalProfile(
        url: url,
        l10n: l10n,
      ),
    );
  }

  Future<void> _downloadResume() {
    return _runPortfolioAction(widget.portfolioActionController.downloadResume);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = widget.portfolioContentRepository.contentFor(l10n.locale);

    return ListenableBuilder(
      listenable: _pageController,
      builder: (context, _) {
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final isPhone = screenWidth < AppBreakpoints.tablet;
        final usesDesktopChat = screenWidth >= AppBreakpoints.desktopChat;

        if (usesDesktopChat && _pageController.isMobileChatOpen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _pageController.closeMobileChat();
          });
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.bgStart,
                  AppColors.bgMiddle,
                  AppColors.bgEnd,
                ],
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: AnimatedBackdrop()),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      20,
                      18,
                      isPhone ? 112 : 140,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth >=
                                AppBreakpoints.desktopContent;
                            final isTablet =
                                constraints.maxWidth >= AppBreakpoints.tablet;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: LanguageSwitcher(),
                                ),
                                const SizedBox(height: 18),
                                HeroSection(
                                  data: content.profile,
                                  isDesktop: isDesktop,
                                  onContactTap: () => unawaited(_openEmail()),
                                  onResumeTap: () =>
                                      unawaited(_downloadResume()),
                                  onGitHubTap: () => unawaited(
                                    _openExternalProfile(
                                        content.profile.github),
                                  ),
                                  onLinkedInTap: () => unawaited(
                                    _openExternalProfile(
                                      content.profile.linkedIn,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                StatsSection(
                                  stats: content.stats,
                                  isTablet: isTablet,
                                ),
                                const SizedBox(height: 28),
                                SectionTitle(
                                  title: l10n.focusSectionTitle,
                                  subtitle: l10n.focusSectionSubtitle,
                                ),
                                const SizedBox(height: 14),
                                FocusCards(
                                  cards: content.focusCards,
                                  isTablet: isTablet,
                                ),
                                const SizedBox(height: 28),
                                SectionTitle(
                                  title: l10n.techStackTitle,
                                  subtitle: l10n.techStackSubtitle,
                                ),
                                const SizedBox(height: 14),
                                SkillCloud(skills: content.skillTags),
                                const SizedBox(height: 30),
                                SectionTitle(
                                  title: l10n.experienceSectionTitle,
                                  subtitle: l10n.experienceSectionSubtitle,
                                ),
                                const SizedBox(height: 14),
                                TimelineSection(items: content.timelineItems),
                                const SizedBox(height: 28),
                                ContactCard(
                                  data: content.profile,
                                  onContactTap: () => unawaited(_openEmail()),
                                  onGitHubTap: () => unawaited(
                                    _openExternalProfile(
                                        content.profile.github),
                                  ),
                                  onLinkedInTap: () => unawaited(
                                    _openExternalProfile(
                                      content.profile.linkedIn,
                                    ),
                                  ),
                                ),
                                if (!usesDesktopChat && !isPhone) ...[
                                  const SizedBox(height: 28),
                                  SectionTitle(
                                    title: l10n.chatSectionTitle,
                                    subtitle: l10n.chatSectionSubtitle,
                                  ),
                                  const SizedBox(height: 14),
                                  ChatPanel(
                                    controllerFactory:
                                        widget.chatControllerFactory,
                                    height: 360,
                                  ),
                                ],
                                const SizedBox(height: 28),
                                Text(
                                  l10n.vibeCodedNote,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                DesktopChatOverlay(
                  chatControllerFactory: widget.chatControllerFactory,
                ),
                if (isPhone)
                  Positioned.fill(
                    child: MobileChatLauncher(
                      isOpen: _pageController.isMobileChatOpen,
                      chatControllerFactory: widget.chatControllerFactory,
                      onToggle: _pageController.toggleMobileChat,
                      onClose: _pageController.closeMobileChat,
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
