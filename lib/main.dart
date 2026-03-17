import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'link_opener/link_opener.dart';
import 'turnstile/turnstile.dart';

void main() {
  runApp(const PortfolioApp());
}

const _desktopContentBreakpoint = 900.0;
const _desktopChatBreakpoint = 980.0;
const _tabletBreakpoint = 700.0;
const _profilePhotoAssetPath = 'assets/picture.jpeg';
const _resumeAssetPath = 'assets/cv.pdf';
const _resumeDownloadPath = 'assets/assets/cv.pdf';
const _contactEmail = 'info@schwarda.com';
const _githubUrl = 'https://github.com/schwarda';
const _linkedInUrl = 'https://www.linkedin.com/in/dávid-schwartz/';

final LinkOpener _linkOpener = createLinkOpener();

Future<bool> _assetExists(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true;
  } catch (_) {
    return false;
  }
}

void _showActionMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _openEmail(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final opened = await _linkOpener.openMailto(
    email: _contactEmail,
    subject: l10n.contactMailSubject,
  );
  if (!context.mounted || opened) {
    return;
  }

  _showActionMessage(context, l10n.linkOpenFailedMessage);
}

Future<void> _openExternalProfileLink(
  BuildContext context,
  String url,
) async {
  final l10n = AppLocalizations.of(context);
  final opened = await _linkOpener.openExternalUrl(url);
  if (!context.mounted || opened) {
    return;
  }

  _showActionMessage(context, l10n.linkOpenFailedMessage);
}

Future<void> _downloadResume(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final hasResume = await _assetExists(_resumeAssetPath);
  if (!context.mounted) {
    return;
  }

  if (!hasResume) {
    _showActionMessage(context, l10n.resumeMissingMessage);
    return;
  }

  final opened = await _linkOpener.downloadPath(
    _resumeDownloadPath,
    suggestedFileName: 'David-Schwartz-CV.pdf',
  );
  if (!context.mounted || opened) {
    return;
  }

  _showActionMessage(context, l10n.resumeOpenFailedMessage);
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late Locale _locale = AppLocalizations.normalizeLocale(
    WidgetsBinding.instance.platformDispatcher.locale,
  );

  void _setLocale(Locale locale) {
    final normalized = AppLocalizations.normalizeLocale(locale);
    if (_locale == normalized) {
      return;
    }

    setState(() {
      _locale = normalized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.spaceGroteskTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).browserTitle,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          brightness: Brightness.dark,
        ),
        textTheme: textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: _AppLocaleScope(
        locale: _locale,
        onLocaleChanged: _setLocale,
        child: const AboutMePage(),
      ),
    );
  }
}

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  bool _isMobileChatOpen = false;

  void _toggleMobileChat() {
    setState(() {
      _isMobileChatOpen = !_isMobileChatOpen;
    });
  }

  void _closeMobileChat() {
    if (!_isMobileChatOpen) {
      return;
    }

    setState(() {
      _isMobileChatOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isPhone = screenWidth < _tabletBreakpoint;
    final usesDesktopChat = screenWidth >= _desktopChatBreakpoint;

    if (usesDesktopChat && _isMobileChatOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isMobileChatOpen = false;
        });
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
            const Positioned.fill(child: _AnimatedBackdrop()),
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
                        final isDesktop =
                            constraints.maxWidth >= _desktopContentBreakpoint;
                        final isTablet =
                            constraints.maxWidth >= _tabletBreakpoint;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: _LanguageSwitcher(),
                            ),
                            const SizedBox(height: 18),
                            _HeroSection(
                              data: l10n.profile,
                              isDesktop: isDesktop,
                            ),
                            const SizedBox(height: 26),
                            _StatsSection(
                              stats: l10n.stats,
                              isTablet: isTablet,
                            ),
                            const SizedBox(height: 28),
                            _SectionTitle(
                              title: l10n.focusSectionTitle,
                              subtitle: l10n.focusSectionSubtitle,
                            ),
                            const SizedBox(height: 14),
                            _FocusCards(
                              cards: l10n.focusCards,
                              isTablet: isTablet,
                            ),
                            const SizedBox(height: 28),
                            _SectionTitle(
                              title: l10n.techStackTitle,
                              subtitle: l10n.techStackSubtitle,
                            ),
                            const SizedBox(height: 14),
                            _SkillCloud(skills: l10n.skillTags),
                            const SizedBox(height: 30),
                            _SectionTitle(
                              title: l10n.experienceSectionTitle,
                              subtitle: l10n.experienceSectionSubtitle,
                            ),
                            const SizedBox(height: 14),
                            _TimelineSection(items: l10n.timelineItems),
                            const SizedBox(height: 28),
                            _ContactCard(data: l10n.profile),
                            if (!usesDesktopChat && !isPhone) ...[
                              const SizedBox(height: 28),
                              _SectionTitle(
                                title: l10n.chatSectionTitle,
                                subtitle: l10n.chatSectionSubtitle,
                              ),
                              const SizedBox(height: 14),
                              const _ChatPanel(
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
            const _DesktopChatOverlay(),
            if (isPhone)
              Positioned.fill(
                child: _MobileChatLauncher(
                  isOpen: _isMobileChatOpen,
                  onToggle: _toggleMobileChat,
                  onClose: _closeMobileChat,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.data,
    required this.isDesktop,
  });

  final ProfileData data;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final intro = _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Text(l10n.portfolioBadge),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.heroGreeting(data.name),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            data.about,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => unawaited(_openEmail(context)),
                icon: const Icon(Icons.email_outlined),
                label: Text(l10n.contactCtaLabel),
              ),
              OutlinedButton.icon(
                onPressed: () => unawaited(_downloadResume(context)),
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.resumeCtaLabel),
              ),
            ],
          ),
        ],
      ),
    );

    final profile = _GlassCard(
      child: Column(
        children: [
          Container(
            width: 108,
            height: 108,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentTeal],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                _profilePhotoAssetPath,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.1),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${data.name} ${data.surname}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.place_outlined,
                  size: 16, color: AppColors.accentTeal),
              const SizedBox(width: 4),
              Text(
                data.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.stroke, height: 1),
          const SizedBox(height: 12),
          _LinkRow(
            label: 'Email',
            value: data.email,
            onTap: () => unawaited(_openEmail(context)),
          ),
          const SizedBox(height: 8),
          _LinkRow(
            label: 'GitHub',
            value: l10n.githubLinkLabel,
            onTap: () =>
                unawaited(_openExternalProfileLink(context, data.github)),
          ),
          const SizedBox(height: 8),
          _LinkRow(
            label: 'LinkedIn',
            value: l10n.linkedInLinkLabel,
            onTap: () =>
                unawaited(_openExternalProfileLink(context, data.linkedin)),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 6, child: intro),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: profile),
          ],
        ),
      );
    }

    return Column(
      children: [
        intro,
        const SizedBox(height: 14),
        profile,
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.stats,
    required this.isTablet,
  });

  final List<StatItem> stats;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final width = isTablet ? 240.0 : 160.0;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats.map((item) {
        return SizedBox(
          width: width,
          child: _GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentBlue,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FocusCards extends StatelessWidget {
  const _FocusCards({
    required this.cards,
    required this.isTablet,
  });

  final List<FocusCardData> cards;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final width = isTablet ? 330.0 : double.infinity;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.map((card) {
        return SizedBox(
          width: width,
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: card.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(card.icon, color: card.color),
                ),
                const SizedBox(height: 12),
                Text(
                  card.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SkillCloud extends StatelessWidget {
  const _SkillCloud({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Text(
              skill,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.items});

  final List<TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 18,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.accentTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 72,
                          color: AppColors.stroke,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.period,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.accentBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.role,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.company,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.data});

  final ProfileData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactSectionTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.contactSectionSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ContactChip(
                icon: Icons.email_outlined,
                label: data.email,
                onTap: () => unawaited(_openEmail(context)),
              ),
              _ContactChip(
                icon: Icons.code_outlined,
                label: l10n.githubLinkLabel,
                onTap: () =>
                    unawaited(_openExternalProfileLink(context, data.github)),
              ),
              _ContactChip(
                icon: Icons.business_center_outlined,
                label: l10n.linkedInLinkLabel,
                onTap: () =>
                    unawaited(_openExternalProfileLink(context, data.linkedin)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesktopChatOverlay extends StatelessWidget {
  const _DesktopChatOverlay();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _desktopChatBreakpoint) {
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
          child: const _ChatPanel(
            width: 340,
            height: 420,
          ),
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeScope = _AppLocaleScope.of(context);
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
          selected: <Locale>{localeScope.locale},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) {
              return;
            }
            localeScope.onLocaleChanged(selection.first);
          },
        ),
      ),
    );
  }
}

class _MobileChatLauncher extends StatelessWidget {
  const _MobileChatLauncher({
    required this.isOpen,
    required this.onToggle,
    required this.onClose,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.padding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final chatHeight = math.min(
      mediaQuery.size.height * 0.72,
      520.0,
    );

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
                child: _ChatPanel(
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

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({
    this.width = double.infinity,
    this.height = 360,
    this.onClose,
  });

  final double width;
  final double height;
  final VoidCallback? onClose;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _BackendChatService _chatService = _BackendChatService();
  late final TurnstileController _turnstileController =
      createTurnstileController(
    siteKey: _chatService.turnstileSiteKey,
    isLocalBypass: _chatService.isLocalHost,
  );
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  bool _isSending = false;
  bool _isUnlocking = false;
  bool _isChatUnlocked = false;
  bool _hasInitializedMessages = false;
  String? _localeCode;

  @override
  void initState() {
    super.initState();
    _isChatUnlocked = !_chatService.requiresUnlock;
    if (_chatService.requiresUnlock) {
      _turnstileController.addListener(_handleTurnstileStateChanged);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    final localeCode = l10n.locale.languageCode;
    final localeChanged = _localeCode != null && _localeCode != localeCode;
    if (_localeCode != localeCode) {
      _localeCode = localeCode;
      _turnstileController.updateLocaleCode(localeCode);
      if (localeChanged) {
        _refreshSeedMessagesIfPossible(l10n);
      }
    }

    if (_hasInitializedMessages) {
      return;
    }

    _hasInitializedMessages = true;
    _messages.addAll(_buildSeedMessages(l10n));

    if (_chatService.requiresUnlock && _chatService.isUnlockConfigured) {
      unawaited(_restoreUnlockState(l10n));
    }
  }

  List<_ChatMessage> _buildSeedMessages(AppLocalizations l10n) {
    final seedMessages = <_ChatMessage>[
      _ChatMessage(
        text: l10n.chatIntroLineOne,
        isUser: false,
        isLocalizedSeed: true,
      ),
      _ChatMessage(
        text: l10n.chatIntroLineTwo,
        isUser: false,
        isLocalizedSeed: true,
      ),
    ];

    if (!_chatService.isConfigured) {
      seedMessages.add(
        _ChatMessage(
          text: l10n.chatNeedsBackendEndpoint,
          isUser: false,
          isError: true,
          isLocalizedSeed: true,
        ),
      );
    }

    if (_chatService.requiresUnlock && !_chatService.isUnlockConfigured) {
      seedMessages.add(
        _ChatMessage(
          text: l10n.chatProtectionMisconfigured,
          isUser: false,
          isError: true,
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

    setState(() {
      _messages
        ..clear()
        ..addAll(_buildSeedMessages(l10n));
    });
  }

  @override
  void dispose() {
    _turnstileController.removeListener(_handleTurnstileStateChanged);
    _turnstileController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTurnstileStateChanged() {
    if (!_chatService.requiresUnlock || _isChatUnlocked || _isUnlocking) {
      return;
    }

    final token = _turnstileController.token?.trim() ?? '';
    if (token.isEmpty) {
      return;
    }

    unawaited(_completeUnlock(token));
  }

  Future<void> _restoreUnlockState(AppLocalizations l10n) async {
    try {
      final unlocked = await _chatService.unlockStatus(l10n: l10n);
      if (!mounted) {
        return;
      }

      setState(() {
        _isChatUnlocked = unlocked;
      });
    } catch (_) {
      // Keep the chat locked until the user explicitly retries.
    }
  }

  void _scrollToBottom() {
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

  void _startUnlockFlow() {
    final l10n = AppLocalizations.of(context);
    if (_isUnlocking || _isChatUnlocked) {
      return;
    }

    if (!_chatService.isUnlockConfigured) {
      _appendErrorMessage(l10n.chatProtectionMisconfigured);
      return;
    }

    _turnstileController.ensureRendered();
  }

  Future<void> _completeUnlock(String turnstileToken) async {
    final l10n = AppLocalizations.of(context);
    if (_isUnlocking || _isChatUnlocked) {
      return;
    }

    setState(() {
      _isUnlocking = true;
    });

    try {
      await _chatService.unlockChat(
        turnstileToken: turnstileToken,
        l10n: l10n,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _isUnlocking = false;
        _isChatUnlocked = true;
      });
    } on _BackendChatException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUnlocking = false;
      });
      _appendErrorMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUnlocking = false;
      });
      _appendErrorMessage(l10n.chatVerificationFailed);
    } finally {
      _turnstileController.close();
      _turnstileController.reset();
    }
  }

  Future<void> _sendMessage() async {
    final l10n = AppLocalizations.of(context);
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    if (!_chatService.isConfigured) {
      _appendErrorMessage(l10n.chatMissingApiUrl);
      return;
    }

    if (_chatService.requiresUnlock && !_isChatUnlocked) {
      _appendErrorMessage(l10n.chatUnlockFirstError);
      return;
    }

    final canCallApi = _chatService.isConfigured;
    _inputController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      if (canCallApi) {
        _messages.add(
          _ChatMessage(
            text: l10n.chatTypingMessage,
            isUser: false,
            isTyping: true,
          ),
        );
        _isSending = true;
      } else {
        _messages.add(
          _ChatMessage(
            text: l10n.chatMissingApiUrl,
            isUser: false,
            isError: true,
          ),
        );
      }
    });
    _scrollToBottom();

    if (!canCallApi) {
      return;
    }

    try {
      final reply = await _chatService.reply(
        messages: _messages.where((message) => !message.isTyping).toList(),
        profileContext: _profileContext(l10n),
        l10n: l10n,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.removeWhere((message) => message.isTyping);
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _isSending = false;
      });
    } on TimeoutException {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.removeWhere((message) => message.isTyping);
        _messages.add(
          _ChatMessage(
            text: l10n.chatProviderTimeout,
            isUser: false,
            isError: true,
          ),
        );
        _isSending = false;
      });
    } on _BackendChatException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.removeWhere((message) => message.isTyping);
        _messages.add(
          _ChatMessage(
            text: error.message,
            isUser: false,
            isError: true,
          ),
        );
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.removeWhere((message) => message.isTyping);
        _messages.add(
          _ChatMessage(
            text: l10n.chatUnexpectedError,
            isUser: false,
            isError: true,
          ),
        );
        _isSending = false;
      });
    }

    _scrollToBottom();
  }

  void _appendErrorMessage(String text) {
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: false,
          isError: true,
        ),
      );
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canCallApi = _chatService.isConfigured;
    final requiresUnlock = _chatService.requiresUnlock;
    final canUseChat = canCallApi && (!requiresUnlock || _isChatUnlocked);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    _isSending ? l10n.chatStatusSending : l10n.chatStatusOnline,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  message.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            )
                          : Text(
                              message.text,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                    ),
                  );
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
                  if (requiresUnlock) ...[
                    AnimatedBuilder(
                      animation: _turnstileController,
                      builder: (context, _) {
                        final statusMessage =
                            _turnstileController.statusMessage;
                        final helperText = statusMessage ??
                            (_isChatUnlocked
                                ? l10n.chatUnlockedForSession
                                : _isUnlocking
                                    ? l10n.chatFinishingVerification
                                    : l10n.chatUnlockBeforeFirstMessage);
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceStrong,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.stroke),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isChatUnlocked
                                    ? Icons.lock_open_rounded
                                    : Icons.shield_outlined,
                                size: 16,
                                color: _isChatUnlocked
                                    ? AppColors.accentTeal
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  helperText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: statusMessage != null
                                            ? const Color(0xFFFFB4AB)
                                            : AppColors.textSecondary,
                                      ),
                                ),
                              ),
                              if (!_isChatUnlocked) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed:
                                      _isUnlocking ? null : _startUnlockFlow,
                                  child: Text(
                                    _isUnlocking
                                        ? l10n.chatUnlockWaiting
                                        : l10n.chatUnlockButton,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          onSubmitted: canUseChat && !_isSending
                              ? (_) => _sendMessage()
                              : null,
                          enabled: canUseChat && !_isSending,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: !canCallApi
                                ? l10n.chatInputHintMissingApi
                                : requiresUnlock && !_isChatUnlocked
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
                            canUseChat && !_isSending ? _sendMessage : null,
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
  }

  String _profileContext(AppLocalizations l10n) {
    final profile = l10n.profile;
    final stats =
        l10n.stats.map((item) => '${item.label}: ${item.value}').join('; ');
    final internalNotes = l10n.internalProfileNotes.join('; ');
    return [
      '${l10n.profileContextNameLabel}: ${profile.name} ${profile.surname}',
      '${l10n.profileContextRoleLabel}: ${profile.title}',
      '${l10n.profileContextLocationLabel}: ${profile.location}',
      '${l10n.profileContextBioLabel}: ${profile.about}',
      '${l10n.profileContextContactLabel}: email ${profile.email}, GitHub ${profile.github}, LinkedIn ${profile.linkedin}',
      '${l10n.profileContextStatsLabel}: $stats',
      '${l10n.profileContextInternalNotesLabel}: $internalNotes',
    ].join('\n');
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.isError = false,
    this.isLocalizedSeed = false,
  });

  final String text;
  final bool isUser;
  final bool isTyping;
  final bool isError;
  final bool isLocalizedSeed;
}

class _BackendChatService {
  static const String _configuredChatApiUrl = String.fromEnvironment(
    'CHAT_API_URL',
    defaultValue: '',
  );
  static const String _turnstileSiteKey = String.fromEnvironment(
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

  bool get isLocalHost {
    final host = Uri.base.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1';
  }

  bool get isConfigured => _chatApiUrl.trim().isNotEmpty;

  bool get requiresUnlock => !isLocalHost;

  bool get isUnlockConfigured =>
      !requiresUnlock || _turnstileSiteKey.trim().isNotEmpty;

  String get turnstileSiteKey => _turnstileSiteKey.trim();

  Uri _requireChatUri(AppLocalizations l10n) {
    final uri = Uri.tryParse(_chatApiUrl);
    if (uri == null) {
      throw _BackendChatException(l10n.chatApiUrlInvalid);
    }
    return uri;
  }

  Uri _unlockUri(AppLocalizations l10n) {
    final chatUri = _requireChatUri(l10n);
    return chatUri.replace(
      path: '${chatUri.path}/unlock',
      queryParameters: <String, String>{
        ...chatUri.queryParameters,
        'locale': l10n.locale.languageCode,
      },
    );
  }

  Map<String, dynamic> _decodeJsonResponse(
    http.Response response, {
    required AppLocalizations l10n,
  }) {
    final responseText = utf8.decode(response.bodyBytes);
    final vercelMitigation = response.headers['x-vercel-mitigated'];
    final looksLikeVercelChallenge = vercelMitigation == 'challenge' ||
        responseText.contains('Vercel Security Checkpoint') ||
        responseText.contains('x-vercel-challenge-token');

    if (looksLikeVercelChallenge) {
      throw _BackendChatException(
        l10n.chatFirewallBlocked,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(responseText);
    } on FormatException {
      if (response.statusCode >= 400) {
        throw _BackendChatException(
          l10n.chatBackendReturnedNonJsonError(response.statusCode),
        );
      }
      throw _BackendChatException(l10n.chatBackendInvalidJson);
    }

    if (decoded is! Map<String, dynamic>) {
      throw _BackendChatException(l10n.chatBackendInvalidResponse);
    }

    if (response.statusCode >= 400) {
      final error = decoded['error'];
      if (error is String && error.trim().isNotEmpty) {
        throw _BackendChatException(error.trim());
      }
      throw _BackendChatException(
        l10n.chatBackendProxyError(response.statusCode),
      );
    }

    return decoded;
  }

  Future<bool> unlockStatus({
    required AppLocalizations l10n,
  }) async {
    final response =
        await http.get(_unlockUri(l10n)).timeout(const Duration(seconds: 15));
    final decoded = _decodeJsonResponse(response, l10n: l10n);
    final unlocked = decoded['unlocked'];
    return unlocked == true;
  }

  Future<void> unlockChat({
    required String turnstileToken,
    required AppLocalizations l10n,
  }) async {
    final response = await http
        .post(
          _unlockUri(l10n),
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'turnstileToken': turnstileToken,
            'locale': l10n.locale.languageCode,
          }),
        )
        .timeout(const Duration(seconds: 30));

    _decodeJsonResponse(response, l10n: l10n);
  }

  Future<String> reply({
    required List<_ChatMessage> messages,
    required String profileContext,
    required AppLocalizations l10n,
  }) async {
    if (!isConfigured) {
      throw _BackendChatException(l10n.chatMissingApiUrl);
    }

    final uri = _requireChatUri(l10n);

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
              'locale': l10n.locale.languageCode,
            }),
          )
          .timeout(const Duration(seconds: 30));
    } on http.ClientException {
      throw _BackendChatException(
        l10n.chatBackendConnectionError(uri.toString()),
      );
    }

    final decoded = _decodeJsonResponse(response, l10n: l10n);

    final reply = decoded['reply'];
    if (reply is String && reply.trim().isNotEmpty) {
      return reply.trim();
    }

    throw _BackendChatException(l10n.chatBackendMissingReply);
  }
}

class _BackendChatException implements Exception {
  const _BackendChatException(this.message);

  final String message;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surfaceStrong,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.accentTeal),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isInteractive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      decoration:
                          isInteractive ? TextDecoration.underline : null,
                      decorationColor: AppColors.accentTeal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
        border: Border.all(color: AppColors.stroke),
      ),
      child: child,
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isInteractive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        decoration:
                            isInteractive ? TextDecoration.underline : null,
                        decorationColor: AppColors.accentTeal,
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop();

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _VibrantBackgroundPainter(t: _controller.value),
          );
        },
      ),
    );
  }
}

class _VibrantBackgroundPainter extends CustomPainter {
  _VibrantBackgroundPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgStart, AppColors.bgMiddle, AppColors.bgEnd],
        ).createShader(rect),
    );

    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.20 + 0.06 * _wave(0.2)),
        size.height * (0.18 + 0.03 * _wave(1.2)),
      ),
      radius: size.width * 0.40,
      color: const Color(0xFF7A5CFF),
      opacity: 0.50,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.84 + 0.04 * _wave(2.4)),
        size.height * (0.24 + 0.04 * _wave(0.6)),
      ),
      radius: size.width * 0.32,
      color: const Color(0xFF00D5FF),
      opacity: 0.40,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.75 + 0.07 * _wave(1.7)),
        size.height * (0.74 + 0.03 * _wave(2.0)),
      ),
      radius: size.width * 0.34,
      color: const Color(0xFFFF6E6A),
      opacity: 0.38,
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(
        size.width * (0.16 + 0.05 * _wave(2.6)),
        size.height * (0.82 + 0.04 * _wave(0.9)),
      ),
      radius: size.width * 0.28,
      color: const Color(0xFF6EF5A9),
      opacity: 0.30,
    );

    _drawRibbon(
      canvas,
      size,
      yFactor: 0.28,
      stroke: 2.0,
      colors: [
        const Color(0x00FFFFFF),
        const Color(0x66FFFFFF),
        const Color(0x00FFFFFF),
      ],
      phase: 0.0,
      amplitude: 28,
    );
    _drawRibbon(
      canvas,
      size,
      yFactor: 0.60,
      stroke: 1.8,
      colors: [
        const Color(0x00FFFFFF),
        const Color(0x55A2D9FF),
        const Color(0x00FFFFFF),
      ],
      phase: 1.4,
      amplitude: 24,
    );
    _drawRibbon(
      canvas,
      size,
      yFactor: 0.82,
      stroke: 1.6,
      colors: [
        const Color(0x00FFFFFF),
        const Color(0x44FFE6C7),
        const Color(0x00FFFFFF),
      ],
      phase: 2.3,
      amplitude: 20,
    );

    _drawNoiseDots(canvas, size);
  }

  void _drawGlow(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(rect)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(center, radius, paint);
  }

  void _drawRibbon(
    Canvas canvas,
    Size size, {
    required double yFactor,
    required double stroke,
    required List<Color> colors,
    required double phase,
    required double amplitude,
  }) {
    final path = Path();
    const step = 14.0;
    final yStart = size.height * yFactor;
    path.moveTo(0, yStart);

    for (double x = 0; x <= size.width; x += step) {
      final y = yStart +
          amplitude *
              (0.9 * _sin((x / size.width) * 2.2 * 3.1415926 + phase) +
                  0.5 * _sin((x / size.width) * 6.2 * 3.1415926 - phase));
      path.lineTo(x, y);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: colors,
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  void _drawNoiseDots(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0x33FFFFFF);
    const int count = 120;

    for (int i = 0; i < count; i++) {
      final fx = ((i * 73) % 997) / 997;
      final fy = ((i * 199) % 991) / 991;
      final shift = (0.008 * _wave(i / 7.0));
      final x = size.width * ((fx + shift) % 1.0);
      final y = size.height * ((fy + shift * 1.7) % 1.0);
      final r = 0.7 + ((i % 4) * 0.25);
      canvas.drawCircle(Offset(x, y), r, dotPaint);
    }
  }

  double _wave(double n) {
    return _sin((t * 2 * 3.1415926) + n);
  }

  double _sin(double value) => math.sin(value);

  @override
  bool shouldRepaint(covariant _VibrantBackgroundPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}

class AppColors {
  static const bgStart = Color(0xFF08111A);
  static const bgMiddle = Color(0xFF0E1D2A);
  static const bgEnd = Color(0xFF101926);

  static const surface = Color(0xAA0C1722);
  static const surfaceStrong = Color(0xCC122232);
  static const stroke = Color(0xFF284156);

  static const textPrimary = Color(0xFFF2F6FA);
  static const textSecondary = Color(0xFFB7C8D6);

  static const accentBlue = Color(0xFF5BA6FF);
  static const accentTeal = Color(0xFF40DFC9);
  static const accentCoral = Color(0xFFFF886B);
}

class _AppLocaleScope extends InheritedWidget {
  const _AppLocaleScope({
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  static _AppLocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppLocaleScope>();
    assert(scope != null, 'Missing _AppLocaleScope in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant _AppLocaleScope oldWidget) {
    return locale != oldWidget.locale;
  }
}

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('sk'),
  ];

  static Locale normalizeLocale(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    if (languageCode.startsWith('sk')) {
      return const Locale('sk');
    }
    return const Locale('en');
  }

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(
      normalizeLocale(Localizations.localeOf(context)),
    );
  }

  bool get isSlovak => locale.languageCode == 'sk';

  String get browserTitle => isSlovak
      ? 'Dávid Schwartz | Frontendový vývojár'
      : 'Dávid Schwartz | Frontend Developer';

  String get portfolioBadge => isSlovak ? 'Portfólio' : 'Portfolio';

  String heroGreeting(String name) =>
      isSlovak ? 'Dobrý deň, som $name' : 'Hello, I am $name';

  String get contactCtaLabel => isSlovak ? 'Kontakt' : 'Contact';

  String get resumeCtaLabel => isSlovak ? 'Stiahnuť CV' : 'Download resume';

  String get focusSectionTitle =>
      isSlovak ? 'Čomu sa venujem' : 'What I focus on';

  String get focusSectionSubtitle => isSlovak
      ? 'Od návrhu UI/UX po frontend architektúru, integrácie a nasadenie.'
      : 'From UI/UX design to frontend architecture, integrations, and deployment.';

  String get techStackTitle => isSlovak ? 'Technologický stack' : 'Tech stack';

  String get techStackSubtitle => isSlovak
      ? 'Nástroje a technológie, s ktorými pracujem denne.'
      : 'Tools and technologies I work with every day.';

  String get experienceSectionTitle => isSlovak ? 'Skúsenosti' : 'Experience';

  String get experienceSectionSubtitle => isSlovak
      ? 'Stručný prehľad môjho posledného profesionálneho obdobia.'
      : 'A concise overview of my recent professional experience.';

  String get chatSectionTitle => isSlovak ? 'Chat' : 'Chat';

  String get chatSectionSubtitle => isSlovak
      ? 'Opýtajte sa na skúsenosti, technológie, projekty alebo spoluprácu.'
      : 'Ask about experience, technologies, projects, or collaboration.';

  String get contactSectionTitle => isSlovak
      ? 'Poďme spolu niečo vytvoriť'
      : 'Let us build something together';

  String get contactSectionSubtitle => isSlovak
      ? 'Ak riešite web, aplikáciu, redizajn alebo výkon frontendu, rád sa o tom porozprávam.'
      : 'If you are working on a website, app, redesign, or frontend performance, I would be glad to discuss it.';

  String get githubLinkLabel => 'GitHub';

  String get linkedInLinkLabel => 'LinkedIn';

  String get contactMailSubject => isSlovak
      ? 'Záujem o spoluprácu cez portfólio'
      : 'Collaboration inquiry from portfolio';

  String get linkOpenFailedMessage => isSlovak
      ? 'Odkaz sa nepodarilo otvoriť.'
      : 'The link could not be opened.';

  String get resumeMissingMessage => isSlovak
      ? 'Pre sťahovanie CV stačí pridať súbor assets/cv.pdf.'
      : 'To enable resume download, add the file assets/cv.pdf.';

  String get resumeOpenFailedMessage => isSlovak
      ? 'CV sa nepodarilo otvoriť.'
      : 'The resume could not be opened.';

  String get vibeCodedNote => isSlovak
      ? 'Táto stránka bola celá vibe coded.'
      : 'This site was fully vibe coded.';

  String get languageOptionSk => 'SK';

  String get languageOptionEn => 'EN';

  String get chatLauncherOpen => isSlovak ? 'Otvoriť chat' : 'Open chat';

  String get chatLauncherClose => isSlovak ? 'Zavrieť chat' : 'Close chat';

  String get chatPanelTitle => isSlovak ? 'Chat' : 'Chat';

  String get chatStatusSending => isSlovak ? 'odpovedá' : 'replying';

  String get chatStatusOnline => isSlovak ? 'online' : 'online';

  String get chatCloseButton => isSlovak ? 'Zavrieť chat' : 'Close chat';

  String get chatIntroLineOne => isSlovak
      ? 'Dobrý deň, odpovedám ako agent portfólia Dávida Schwartza.'
      : 'Hello, this chat responds as Dávid Schwartz’s portfolio agent.';

  String get chatIntroLineTwo => isSlovak
      ? 'Môžete sa opýtať na skúsenosti, technologický stack, projekty alebo spoluprácu.'
      : 'You can ask about experience, tech stack, projects, or collaboration.';

  String get chatNeedsBackendEndpoint => isSlovak
      ? 'Chat potrebuje backend endpoint. Spustite aplikáciu s parametrom --dart-define=CHAT_API_URL=...'
      : 'The chat needs a backend endpoint. Start the app with --dart-define=CHAT_API_URL=...';

  String get chatProtectionMisconfigured => isSlovak
      ? 'Ochrana chatu nie je správne nakonfigurovaná. Chýba TURNSTILE_SITE_KEY.'
      : 'Chat protection is not configured correctly. TURNSTILE_SITE_KEY is missing.';

  String get chatVerificationFailed => isSlovak
      ? 'Bezpečnostné overenie zlyhalo. Skúste to, prosím, ešte raz.'
      : 'Security verification failed. Please try again.';

  String get chatMissingApiUrl => isSlovak
      ? 'Chýba CHAT_API_URL. Bez backend endpointu nie je možné volať AI službu.'
      : 'CHAT_API_URL is missing. The AI service cannot be called without a backend endpoint.';

  String get chatUnlockFirstError => isSlovak
      ? 'Pred odoslaním správy najprv odomknite chat.'
      : 'Please unlock the chat before sending a message.';

  String get chatTypingMessage => isSlovak
      ? 'Agent pripravuje odpoveď...'
      : 'The agent is preparing a reply...';

  String get chatProviderTimeout => isSlovak
      ? 'AI služba neodpovedala včas. Skúste to, prosím, ešte raz.'
      : 'The AI service did not respond in time. Please try again.';

  String get chatUnexpectedError => isSlovak
      ? 'Pri volaní AI služby nastala neočakávaná chyba.'
      : 'An unexpected error occurred while calling the AI service.';

  String get chatUnlockedForSession => isSlovak
      ? 'Chat je pre túto reláciu odomknutý.'
      : 'The chat is unlocked for this session.';

  String get chatFinishingVerification => isSlovak
      ? 'Dokončuje sa bezpečnostné overenie...'
      : 'Security verification is being completed...';

  String get chatUnlockBeforeFirstMessage => isSlovak
      ? 'Pred prvou správou odomknite chat jedným overením.'
      : 'Unlock the chat with a single verification before sending the first message.';

  String get chatUnlockWaiting => isSlovak ? 'Čakajte...' : 'Please wait...';

  String get chatUnlockButton => isSlovak ? 'Odomknúť chat' : 'Unlock chat';

  String get chatInputHintMissingApi => isSlovak
      ? 'Spustite aplikáciu s CHAT_API_URL'
      : 'Start the app with CHAT_API_URL';

  String get chatInputHintUnlockFirst =>
      isSlovak ? 'Najprv odomknite chat' : 'Unlock the chat first';

  String get chatInputHint =>
      isSlovak ? 'Napíšte správu...' : 'Write a message...';

  String get profileContextNameLabel => isSlovak ? 'Meno' : 'Name';

  String get profileContextRoleLabel => isSlovak ? 'Rola' : 'Role';

  String get profileContextLocationLabel => isSlovak ? 'Lokalita' : 'Location';

  String get profileContextBioLabel => isSlovak ? 'Profil' : 'Profile';

  String get profileContextContactLabel => isSlovak ? 'Kontakt' : 'Contact';

  String get profileContextStatsLabel => isSlovak ? 'Štatistiky' : 'Stats';

  String get profileContextInternalNotesLabel =>
      isSlovak ? 'Interný kontext' : 'Internal context';

  String get chatApiUrlInvalid => isSlovak
      ? 'CHAT_API_URL nie je platná URL adresa.'
      : 'CHAT_API_URL is not a valid URL.';

  String get chatFirewallBlocked => isSlovak
      ? 'Vercel Firewall blokuje chat API challenge stránkou. Vo Vercel projekte nastavte Bot Protection na Log Only alebo vytvorte Bypass rule pre /api/chat a /api/chat/unlock.'
      : 'Vercel Firewall is blocking the chat API with a challenge page. In the Vercel project, set Bot Protection to Log Only or create a bypass rule for /api/chat and /api/chat/unlock.';

  String chatBackendReturnedNonJsonError(int statusCode) => isSlovak
      ? 'Backend vrátil chybu ($statusCode), ale nie vo formáte JSON.'
      : 'The backend returned an error ($statusCode), but not in JSON format.';

  String get chatBackendInvalidJson => isSlovak
      ? 'Backend vrátil neplatnú JSON odpoveď.'
      : 'The backend returned invalid JSON.';

  String get chatBackendInvalidResponse => isSlovak
      ? 'Backend vrátil neplatnú odpoveď.'
      : 'The backend returned an invalid response.';

  String chatBackendProxyError(int statusCode) => isSlovak
      ? 'Backend chat proxy vrátil chybu ($statusCode).'
      : 'The chat backend proxy returned an error ($statusCode).';

  String chatBackendConnectionError(String uri) => isSlovak
      ? 'Nepodarilo sa spojiť s chat backendom na $uri. Skontrolujte, či backend beží a či endpoint povoľuje CORS.'
      : 'Could not connect to the chat backend at $uri. Check whether the backend is running and whether the endpoint allows CORS.';

  String get chatBackendMissingReply => isSlovak
      ? 'Backend nevrátil textovú odpoveď.'
      : 'The backend did not return a text response.';

  ProfileData get profile => isSlovak ? _profileDataSk : _profileDataEn;

  List<StatItem> get stats => isSlovak ? _statsDataSk : _statsDataEn;

  List<FocusCardData> get focusCards =>
      isSlovak ? _focusCardsSk : _focusCardsEn;

  List<String> get skillTags => _skillTags;

  List<TimelineItem> get timelineItems =>
      isSlovak ? _timelineDataSk : _timelineDataEn;

  List<String> get internalProfileNotes =>
      isSlovak ? _internalProfileNotesSk : _internalProfileNotesEn;
}

class ProfileData {
  const ProfileData({
    required this.name,
    required this.surname,
    required this.initials,
    required this.title,
    required this.location,
    required this.about,
    required this.email,
    required this.github,
    required this.linkedin,
  });

  final String name;
  final String surname;
  final String initials;
  final String title;
  final String location;
  final String about;
  final String email;
  final String github;
  final String linkedin;
}

class StatItem {
  const StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;
}

class FocusCardData {
  const FocusCardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class TimelineItem {
  const TimelineItem({
    required this.period,
    required this.role,
    required this.company,
    required this.description,
  });

  final String period;
  final String role;
  final String company;
  final String description;
}

const _profileDataSk = ProfileData(
  name: 'Dávid',
  surname: 'Schwartz',
  initials: 'DS',
  title: 'Frontendový vývojár',
  location: 'Bratislava, Slovensko',
  about:
      'Navrhujem a vyvíjam moderné frontendové riešenia pre web aj mobil. Spájam '
      'produktové uvažovanie, čistú architektúru, výkon a UI, ktoré pôsobí premyslene.',
  email: _contactEmail,
  github: _githubUrl,
  linkedin: _linkedInUrl,
);

const _profileDataEn = ProfileData(
  name: 'Dávid',
  surname: 'Schwartz',
  initials: 'DS',
  title: 'Frontend developer',
  location: 'Bratislava, Slovakia',
  about:
      'I design and build modern frontend experiences for web and mobile. I care about '
      'product thinking, clean architecture, performance, and UI that feels deliberate.',
  email: _contactEmail,
  github: _githubUrl,
  linkedin: _linkedInUrl,
);

const _statsDataSk = [
  StatItem(value: '3+ roky', label: 'Skúsenosti s frontendovým vývojom'),
  StatItem(value: '5', label: 'Dokončených projektov'),
  StatItem(value: '100 %', label: 'Dôraz na UX a výkon'),
];

const _statsDataEn = [
  StatItem(value: '3+ years', label: 'Experience in frontend development'),
  StatItem(value: '5', label: 'Completed projects'),
  StatItem(value: '100%', label: 'Focus on UX and performance'),
];

const _internalProfileNotesSk = [
  'Má 26 rokov, pochádza z Popradu a momentálne žije v Bratislave.',
  'Narodil sa 4. februára 2000.',
  'Študoval informatiku, no programovať sa naučil najmä ako samouk cez online zdroje, kurzy a prax.',
  'Strednú školu vyštudoval v Poprade v odbore elektrotechnika.',
  'Vysokú školu začal v Košiciach v odbore kyberbezpečnosť, no po bakalárskom ročníku nastúpil na plný úväzok.',
  'Programovaniu sa venuje od strednej školy, profesionálne pracuje od roku 2022.',
  'Hlavnou špecializáciou je frontendový vývoj webových a mobilných produktov, pričom silný kontext má vo Flutteri a rozumie aj backendovým integráciám a celému životnému cyklu aplikácií.',
  'Najradšej pracuje na projektoch, kde môže navrhovať a realizovať UX zlepšenia a optimalizovať výkon.',
  'Ideálny projekt je taký, kde má vplyv na UX, UI aj výkon a kde je dôležitá konzistentnosť kódu.',
  'Najsilnejší technický kontext má v modernom frontendovom vývoji, najmä vo Flutteri a Darte.',
  'Zakladá si na čistej architektúre, SOLID princípoch, výkone a konzistentnom UI na mobile aj desktope.',
  'Rozumie aj backendovým integráciám, najmä REST API, autentifikácii, analytike a cloudovým službám.',
  'V TATRAMED-e pracuje na medicínskom produkte TOMOCON pre lekárov, kde sa venuje najmä frontendu, navrhuje UX/UI zlepšenia, zavádza testy a optimalizuje výkon.',
  'Absolvoval uznávaný UX/UI kurz od SUXA: https://www.suxa.sk/uvod-do-ux',
  'Ako freelancer pre Novú Jar vyvíja mobilnú aplikáciu pre komunitu, podcasty, e-knihy a eventy, ktorú môže ukázať na pohovore.',
  'Pri technických odpovediach je vhodné zdôrazňovať pragmatický prístup, dopad na UX a udržateľnosť riešenia.',
  'Preferuje pracovný pomer ako zamestnanec a ideálne 100 % home office.',
  'Platové očakávanie je približne 2 500 až 3 000 EUR brutto mesačne.',
  'Má skúsenosti s agilným vývojom a Scrumom.',
  'Pri práci zvyčajne najprv zanalyzuje problém písomne alebo pomocou diagramu, potom ho rozdelí na menšie tasky.',
  'Veľkosť tasku sa snaží držať približne na jeden deň práce; ak je väčší, rozdelí ho na ešte menšie časti.',
  'Profesijne sa vníma ako medior frontend developer.',
  'Projekty rád ukáže na pohovore alebo pri úvodnom kontakte, ak o ne bude záujem.',
  'Používal napríklad Flutter, Dart, Riverpod, go_router, Firebase, Firestore, Firebase Storage, Firebase Analytics, Secure Storage, REST API, HTTP, epubx, flutter_inappwebview, share_plus, url_launcher, just_audio, Next.js, React, TypeScript, Sanity, GROQ, Styled Components, Tailwind CSS, Zod, Resend, Google Fonts, Vercel, GitHub Actions, Codex, GitHub Copilot a Grok.',
  'Pri otázkach na knižnice a nástroje má odpovedať stručným reprezentatívnym výberom; celý zoznam má rozpisovať len na výslovné vyžiadanie.',
  'Ak odpoveď nie je v profile, má uviesť, že Dávid na ňu rád odpovie na pohovore.',
  'Vo voľnom čase sa venuje cvičeniu s vlastnou váhou aj činkami, vareniu a lietaniu s dronom.',
  'Zaujímavosťou je zoskok z lietadla zo štyroch kilometrov, hoci pri pracovných témach to nebýva podstatné.',
  'Medzi silné stránky patrí analytické myslenie, schopnosť hľadať netradičné riešenia a dôraz na detail.',
];

const _internalProfileNotesEn = [
  'He is 26 years old, comes from Poprad, and currently lives in Bratislava.',
  'He was born on 4 February 2000.',
  'He studied computer science, but he learned programming mainly as a self-taught developer through online resources, courses, and practice.',
  'He attended secondary school in Poprad, specialising in electrical engineering.',
  'He started university studies in Kosice in cybersecurity, but after the first bachelor year he moved into full-time work.',
  'He has been programming since secondary school and has worked professionally since 2022.',
  'His main specialisation is frontend development for web and mobile products, with strong Flutter experience and a solid understanding of backend integrations and the full application lifecycle.',
  'He prefers projects where he can design and implement UX improvements and optimise performance.',
  'The ideal project is one where he can influence UX, UI, and performance while maintaining code consistency.',
  'His strongest technical context is in modern frontend development, especially Flutter and Dart.',
  'He values clean architecture, SOLID principles, performance, and consistent UI across mobile and desktop.',
  'He also understands backend integrations, especially REST APIs, authentication, analytics, and cloud services.',
  'At TATRAMED, he works on TOMOCON, a medical product for doctors, focusing mainly on frontend work, UX/UI improvements, tests, and performance optimisation.',
  'He completed a respected UX/UI course by SUXA: https://www.suxa.sk/uvod-do-ux',
  'As a freelancer for Nova Jar, he is building a mobile app for a community, podcasts, e-books, and events, which he can present during interviews.',
  'In technical answers, it is useful to emphasise his pragmatic approach, UX impact, and long-term maintainability.',
  'He prefers full-time employment and ideally 100% remote work from home.',
  'His salary expectation is roughly EUR 2,500 to 3,000 gross per month.',
  'He has experience with agile development and Scrum.',
  'When working on a problem, he usually starts by analysing it in writing or by drawing a diagram and then breaks it down into smaller tasks.',
  'He tries to keep tasks to roughly one day of work; if a task grows beyond that, he splits it into smaller parts.',
  'He sees himself professionally as a mid-level frontend developer.',
  'He is happy to present his projects during an interview or early contact if there is interest.',
  'He has worked with tools and libraries such as Flutter, Dart, Riverpod, go_router, Firebase, Firestore, Firebase Storage, Firebase Analytics, Secure Storage, REST APIs, HTTP, epubx, flutter_inappwebview, share_plus, url_launcher, just_audio, Next.js, React, TypeScript, Sanity, GROQ, Styled Components, Tailwind CSS, Zod, Resend, Google Fonts, Vercel, GitHub Actions, Codex, GitHub Copilot, and Grok.',
  'When asked about libraries and tools, he should provide a concise representative summary instead of dumping the full list unless detailed enumeration is explicitly requested.',
  'If an answer is not in the profile, the response should say that Dávid will be happy to answer it during an interview.',
  'In his free time, he enjoys bodyweight training, weights, cooking, and flying drones.',
  'A personal detail: he has completed a skydive from four kilometres, although that is not usually relevant in professional discussions.',
  'His strengths include analytical thinking, an ability to find unconventional solutions, and strong attention to detail.',
];

const _focusCardsSk = [
  FocusCardData(
    icon: Icons.design_services_outlined,
    title: 'Frontend, ktorý funguje',
    description:
        'Návrh obrazoviek od wireframu po finálnu implementáciu s dôrazom na konzistenciu, zrozumiteľnosť a detail.',
    color: AppColors.accentBlue,
  ),
  FocusCardData(
    icon: Icons.flash_on_outlined,
    title: 'Výkon a stabilita',
    description:
        'Profilovanie, optimalizácia renderu a plynulé animácie aj pri náročnejších scénach.',
    color: AppColors.accentTeal,
  ),
  FocusCardData(
    icon: Icons.hub_outlined,
    title: 'Integrácie a backend',
    description:
        'REST/GraphQL, autentifikácia, push notifikácie, analytika a napojenie na cloudové služby.',
    color: AppColors.accentCoral,
  ),
];

const _focusCardsEn = [
  FocusCardData(
    icon: Icons.design_services_outlined,
    title: 'Frontend that performs',
    description:
        'Screen design from wireframes to final implementation with a strong focus on consistency, clarity, and detail.',
    color: AppColors.accentBlue,
  ),
  FocusCardData(
    icon: Icons.flash_on_outlined,
    title: 'Performance and stability',
    description:
        'Profiling, render optimisation, and smooth animations even in more demanding scenarios.',
    color: AppColors.accentTeal,
  ),
  FocusCardData(
    icon: Icons.hub_outlined,
    title: 'Integrations and backend',
    description:
        'REST/GraphQL, authentication, push notifications, analytics, and cloud integrations.',
    color: AppColors.accentCoral,
  ),
];

const _skillTags = [
  'Flutter',
  'Dart',
  'Firebase',
  'Riverpod',
  'Bloc',
  'Clean Architecture',
  'REST APIs',
  'CI/CD',
  'Figma',
  'Codex',
  'GitHub Copilot',
  'Grok',
  'GitHub Actions',
  'Unit & Widget Tests',
];

const _timelineDataSk = [
  TimelineItem(
    period: '2023 - súčasnosť',
    role: 'Frontendový softvérový vývojár',
    company: 'TATRAMED s.r.o.',
    description:
        'Frontendový vývoj medicínskej aplikácie TOMOCON pre lekárov, vrátane UX/UI zlepšení a optimalizácie výkonu.',
  ),
  TimelineItem(
    period: '2025 - súčasnosť',
    role: 'Freelance full stack developer',
    company: 'Nová Jar',
    description:
        'Návrh a vývoj mobilnej aplikácie pre komunitu so zameraním na podcasty, e-knihy a komunitné udalosti.',
  ),
  TimelineItem(
    period: '2022 - 2023',
    role: 'Frontendový softvérový vývojár',
    company: 'Startup tím APONI s.r.o.',
    description:
        'Začiatok profesionálnej kariéry, refaktorovanie legacy častí aplikácie a postupné zavádzanie testov.',
  ),
];

const _timelineDataEn = [
  TimelineItem(
    period: '2023 - Present',
    role: 'Frontend developer',
    company: 'TATRAMED s.r.o.',
    description:
        'Frontend development of TOMOCON, a medical application for doctors, including UX/UI improvements and performance optimisation.',
  ),
  TimelineItem(
    period: '2025 - Present',
    role: 'Freelance full stack developer',
    company: 'Nova Jar',
    description:
        'Design and development of a mobile app for a community focused on podcasts, e-books, and community events.',
  ),
  TimelineItem(
    period: '2022 - 2023',
    role: 'Frontend developer',
    company: 'APONI startup team s.r.o.',
    description:
        'The start of his professional career, including refactoring legacy parts of the app and gradually introducing tests.',
  ),
];
