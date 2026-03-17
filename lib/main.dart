import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'turnstile/turnstile.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.spaceGroteskTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'About Me Portfolio',
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
      home: const AboutMePage(),
    );
  }
}

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 140),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;
                        final isTablet = constraints.maxWidth >= 700;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroSection(
                              data: profileData,
                              isDesktop: isDesktop,
                            ),
                            const SizedBox(height: 26),
                            _StatsSection(
                              stats: statsData,
                              isTablet: isTablet,
                            ),
                            const SizedBox(height: 28),
                            const _SectionTitle(
                              title: 'Čomu sa venujem',
                              subtitle:
                                  'Od UI/UX návrhu po backend napojenie a deployment.',
                            ),
                            const SizedBox(height: 14),
                            _FocusCards(
                              cards: focusCards,
                              isTablet: isTablet,
                            ),
                            const SizedBox(height: 28),
                            const _SectionTitle(
                              title: 'Tech stack',
                              subtitle: 'Nástroje, ktoré denne používam.',
                            ),
                            const SizedBox(height: 14),
                            const _SkillCloud(skills: skillTags),
                            const SizedBox(height: 30),
                            const _SectionTitle(
                              title: 'Skúsenosti',
                              subtitle:
                                  'Krátky prehľad môjho posledného obdobia.',
                            ),
                            const SizedBox(height: 14),
                            const _TimelineSection(items: timelineData),
                            const SizedBox(height: 28),
                            const _ContactCard(data: profileData),
                            if (!isDesktop) ...[
                              const SizedBox(height: 28),
                              const _SectionTitle(
                                title: 'Chat so mnou',
                                subtitle:
                                    'Rýchla ukážka konverzácie priamo na stránke.',
                              ),
                              const SizedBox(height: 14),
                              const _ChatPanel(
                                height: 360,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const _DesktopChatOverlay(),
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
            child: const Text('Moje Portfolio'),
          ),
          const SizedBox(height: 18),
          Text(
            'Ahoj, som ${data.name}',
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Dopln sem odkaz na kontakt alebo formulár.'),
                    ),
                  );
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text('Kontaktuj ma'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dopln sem odkaz na CV alebo portfólio.'),
                    ),
                  );
                },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Stiahnuť CV'),
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
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentTeal],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              data.initials,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
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
          _LinkRow(label: 'Email', value: data.email),
          const SizedBox(height: 8),
          _LinkRow(label: 'GitHub', value: data.github),
          const SizedBox(height: 8),
          _LinkRow(label: 'LinkedIn', value: data.linkedin),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: intro),
          const SizedBox(width: 16),
          Expanded(flex: 4, child: profile),
        ],
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
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Poďme spolu niečo postaviť',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ak riešiš appku, redizajn alebo performance tuning vo Flutteri, ozvi sa.',
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
              _ContactChip(icon: Icons.email_outlined, label: data.email),
              _ContactChip(icon: Icons.code_outlined, label: data.github),
              _ContactChip(
                  icon: Icons.business_center_outlined, label: data.linkedin),
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
    if (screenWidth < 980) {
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

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({
    this.width = double.infinity,
    this.height = 360,
  });

  final double width;
  final double height;

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

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(
        text: 'Ahoj, odpovedám o majiteľovi tohto portfólia.',
        isUser: false,
      ),
    );
    _messages.add(
      const _ChatMessage(
        text: 'Opýtaj sa na skúsenosti, stack, projekty alebo spoluprácu.',
        isUser: false,
      ),
    );
    if (!_chatService.isConfigured) {
      _messages.add(
        const _ChatMessage(
          text:
              'Chat potrebuje backend endpoint. Spusť appku s --dart-define=CHAT_API_URL=...',
          isUser: false,
          isError: true,
        ),
      );
    }
    if (!_chatService.isBotProtectionConfigured) {
      _messages.add(
        const _ChatMessage(
          text:
              'Chat na produkcii vyžaduje Turnstile ochranu. Nastav TURNSTILE_SITE_KEY.',
          isUser: false,
          isError: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _turnstileController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    if (!_chatService.isConfigured) {
      _appendErrorMessage(
        'Chýba CHAT_API_URL. Bez backend endpointu chat nevie volať AI API.',
      );
      return;
    }

    if (!_chatService.isBotProtectionConfigured) {
      _appendErrorMessage(
        'Chýba TURNSTILE_SITE_KEY. Chat na produkcii je z bezpečnostných dôvodov vypnutý.',
      );
      return;
    }

    if (_chatService.requiresTurnstile && !_turnstileController.hasValidToken) {
      _turnstileController.ensureRendered();
      _appendErrorMessage(
        'Dokonči bezpečnostnú kontrolu a potom odošli správu.',
      );
      return;
    }

    final canCallApi = _chatService.isConfigured;
    final turnstileToken = _turnstileController.token;
    _inputController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      if (canCallApi) {
        _messages.add(
          const _ChatMessage(
            text: 'AI píše...',
            isUser: false,
            isTyping: true,
          ),
        );
        _isSending = true;
      } else {
        _messages.add(
          const _ChatMessage(
            text:
                'Chýba CHAT_API_URL. Bez backend endpointu chat nevie volať AI API.',
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
        profileContext: _profileContext,
        turnstileToken: turnstileToken,
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
          const _ChatMessage(
            text: 'OpenAI neodpovedal včas. Skús to prosím ešte raz.',
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
          const _ChatMessage(
            text: 'Nastala neočakávaná chyba pri volaní OpenAI API.',
            isUser: false,
            isError: true,
          ),
        );
        _isSending = false;
      });
    } finally {
      if (_chatService.requiresTurnstile) {
        _turnstileController.reset();
      }
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
    final canCallApi = _chatService.isConfigured;
    final isChatConfigured =
        canCallApi && _chatService.isBotProtectionConfigured;
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
                    'Live Chat',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    _isSending ? 'odpoveda...' : 'online',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
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
                  if (_chatService.requiresTurnstile &&
                      _chatService.isBotProtectionConfigured) ...[
                    AnimatedBuilder(
                      animation: _turnstileController,
                      builder: (context, _) {
                        final statusMessage = _turnstileController.statusMessage;
                        final hasValidToken =
                            _turnstileController.hasValidToken;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
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
                                    hasValidToken
                                        ? Icons.verified_user_rounded
                                        : Icons.shield_outlined,
                                    size: 16,
                                    color: hasValidToken
                                        ? AppColors.accentTeal
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      statusMessage ??
                                          (hasValidToken
                                              ? 'Overenie pripravené. Môžeš písať a odoslať správu.'
                                              : _turnstileController.isLoading
                                                  ? 'Otváram bezpečnostné overenie...'
                                                  : 'Pred prvým odoslaním otvor bezpečnostné overenie.'),
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
                                  if (!hasValidToken) ...[
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: _isSending
                                          ? null
                                          : _turnstileController.ensureRendered,
                                      child: const Text('Overiť'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          onSubmitted: isChatConfigured && !_isSending
                              ? (_) => _sendMessage()
                              : null,
                          enabled: isChatConfigured && !_isSending,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: !canCallApi
                                ? 'Spusti appku s CHAT_API_URL'
                                : !_chatService.isBotProtectionConfigured
                                    ? 'Nastav TURNSTILE_SITE_KEY'
                                    : 'Napíš správu...',
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
                        onPressed: isChatConfigured && !_isSending
                            ? _sendMessage
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
  }

  String get _profileContext {
    final stats =
        statsData.map((item) => '${item.label}: ${item.value}').join('; ');
    final internalNotes = internalProfileNotes.join('; ');
    return [
      'Meno: ${profileData.name}',
      'Rola: ${profileData.title}',
      'Lokacia: ${profileData.location}',
      'Bio: ${profileData.about}',
      'Kontakt: email ${profileData.email}, GitHub ${profileData.github}, LinkedIn ${profileData.linkedin}',
      'Statistiky: $stats',
      'Interny kontext: $internalNotes',
    ].join('\n');
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final bool isTyping;
  final bool isError;
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

  String get turnstileSiteKey => _turnstileSiteKey.trim();

  bool get requiresTurnstile => !isLocalHost;

  bool get isBotProtectionConfigured =>
      !requiresTurnstile || turnstileSiteKey.isNotEmpty;

  Future<String> reply({
    required List<_ChatMessage> messages,
    required String profileContext,
    String? turnstileToken,
  }) async {
    if (!isConfigured) {
      throw const _BackendChatException('Chýba CHAT_API_URL.');
    }

    final uri = Uri.tryParse(_chatApiUrl);
    if (uri == null) {
      throw const _BackendChatException(
        'CHAT_API_URL nie je platná URL adresa.',
      );
    }

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
              if ((turnstileToken ?? '').trim().isNotEmpty)
                'turnstileToken': turnstileToken!.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));
    } on http.ClientException {
      throw _BackendChatException(
        'Nepodarilo sa spojiť s chat backendom na ${uri.toString()}. '
        'Skontroluj, či backend beží a či endpoint povoľuje CORS.',
      );
    }

    final responseText = utf8.decode(response.bodyBytes);
    dynamic decoded;
    try {
      decoded = jsonDecode(responseText);
    } on FormatException {
      if (response.statusCode >= 400) {
        throw _BackendChatException(
          'Backend vrátil chybu (${response.statusCode}), ale nie vo formáte JSON.',
        );
      }
      throw const _BackendChatException('Backend vrátil neplatnú JSON odpoveď.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const _BackendChatException('Neplatná odpoveď z backendu.');
    }

    if (response.statusCode >= 400) {
      final error = decoded['error'];
      if (error is String && error.trim().isNotEmpty) {
        throw _BackendChatException(error.trim());
      }
      throw _BackendChatException(
        'Backend chat proxy vrátil chybu (${response.statusCode}).',
      );
    }

    final reply = decoded['reply'];
    if (reply is String && reply.trim().isNotEmpty) {
      return reply.trim();
    }

    throw const _BackendChatException('Backend nevrátil textovú odpoveď.');
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
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  color: AppColors.textSecondary,
                ),
          ),
        ],
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
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

const profileData = ProfileData(
  name: 'Dávid',
  surname: 'Schwartz',
  initials: 'DS',
  title: 'Frontend software developer',
  location: 'Bratislava, Slovensko',
  about:
      'Vytváram moderné mobilné a webové aplikácie. Mám rád čistú architektúru, '
      'výkon a UI, ktoré pôsobí premyslene na desktop aj mobile.',
  email: 'schwartzd14@gmail.com',
  github: 'https://github.com/schwarda',
  linkedin: 'https://www.linkedin.com/in/dávid-schwartz/',
);

const statsData = [
  StatItem(value: '3+ roky', label: 'Skúsenosti s frontend vývojom'),
  StatItem(value: '5', label: 'Dokončených projektov'),
  StatItem(value: '100%', label: 'Fokus na UX a výkon'),
];

const internalProfileNotes = [
  'Mam 26 rokov, pochadzam z Popradu a momentalne zijem v Bratislave',
  'Chodil som na informatiku, ale programovanie som sa naučil hlavne samouǩom, cez online zdroje, kurzy a praxou',
  'Stredna skola v Poprade, odbor elektrotechnika',
  'Vysoka skola v Kosiciach, odbor kyberbezpecnost po bakalarskom rocniku som zacal pracovat na plny uvazok',
  'Programovaniu sa venujem od strednej skoly, ale profesionalne som zacal pracovat az v roku 2022',
  'Mojou hlavnou specializaciou je frontend vyvoj mobilnych a webovych aplikacii vo Flutteri, ale rozumiem aj backend integraciam a celkovemu lifecycle appiek',
  'Najradsej pracujem na projektoch, kde mozem navrhovat a realizovat UX zlepsenia, optimalizovat vykon',
  'Mojim idealnym projektom je ten, kde mozem mat vplyv na UX, UI a vykon, a kde sa kladie dolezitost na konzistenciu kodu',
  'Najsilnejsi kontext mam pre frontend vyvoj vo Flutteri a Darte',
  'Zakladam si na cistej architekture, SOLID principoch, vykone a konzistentnom UI na mobile aj desktope',
  'Rozumiem aj backend integraciam, hlavne REST API, autentifikacii, analytics a cloud sluzbam',
  'V TATRAMED-e pracujem na medicinskom produkte pre lekarov - TOMOCON, kde sa venujem hlavne frontendovej casti, navrhujem UX / UI zlepsenia a postupne zavadzam testy a optimalizujem vykon',
  'Spravil som velmi znavany UX / UI kurz cez SUXA (https://www.suxa.sk/uvod-do-ux)',
  'Ako freelancer pre Novú Jar riesim mobilnu aplikaciu pre komunitu, podcasty, e-knihy a eventy, ktoru viem ukazat na pohovore',
  'Pri technickych odpovediach je dobre zdoraznit pragmaticky pristup, UX dopad a udrziavatelnost riesenia',
  'Moje zaluby su posilnovanie s vlastnou vahou alebo kombinacia s cinkami, ked sa mi chce tak varenia a lietanie s dronom',
  'Zaujimave info o mne ze som skocil z lietadla zo 4km vysky, ale to asi na pohovore neriesime',
  'Moje silne stranky su analyticke myslenie, rozmyslanie out of the box, zameranie na detail.'
];

const focusCards = [
  FocusCardData(
    icon: Icons.design_services_outlined,
    title: 'UI, ktoré predáva',
    description:
        'Návrh obrazoviek od wireframu po pixel-perfect implementáciu s dôrazom na konzistenciu.',
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
        'REST/GraphQL, autentifikácia, push notifikácie, analytics a napojenie na cloud služby.',
    color: AppColors.accentCoral,
  ),
];

const skillTags = [
  'Flutter',
  'Dart',
  'Firebase',
  'Riverpod',
  'Bloc',
  'Clean Architecture',
  'REST APIs',
  'CI/CD',
  'Figma',
  'GitHub Actions',
  'Unit & Widget Tests',
];

const timelineData = [
  TimelineItem(
    period: '2023 - dnes',
    role: 'Frontend software developer',
    company: 'TATRAMED s.r.o.',
    description: 'Frontend vývoj, medicínskej aplikácie pre lekárov, TOMOCON-u',
  ),
  TimelineItem(
    period: '2025 - dnes',
    role: 'Freelance full stack developer',
    company: 'Nová Jar',
    description:
        'Návrh a vývoj mobilnej appky pre katolícku komunitu, na počúvanie podcastov, čítanie e-kníh a sledovanie udalostí v komunite.',
  ),
  TimelineItem(
    period: '2022 - 2023',
    role: 'Frontend software developer',
    company: 'Startup tím APONI s.r.o.',
    description:
        'Začiatok mojej kariérnej cesty, refaktor legacy častí appky a postupné zavedenie testov.',
  ),
];
