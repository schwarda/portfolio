import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/portfolio_content.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.data,
    required this.isDesktop,
    required this.onContactTap,
    required this.onResumeTap,
    required this.onGitHubTap,
    required this.onLinkedInTap,
  });

  final ProfileData data;
  final bool isDesktop;
  final VoidCallback onContactTap;
  final VoidCallback onResumeTap;
  final VoidCallback onGitHubTap;
  final VoidCallback onLinkedInTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final intro = GlassCard(
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
          if (isDesktop) const Spacer() else const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onContactTap,
                icon: const Icon(Icons.email_outlined),
                label: Text(l10n.contactCtaLabel),
              ),
              OutlinedButton.icon(
                onPressed: onResumeTap,
                icon: const Icon(Icons.download_outlined),
                label: Text(l10n.resumeCtaLabel),
              ),
            ],
          ),
        ],
      ),
    );

    final profile = GlassCard(
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
                PortfolioAssets.profilePhoto,
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
              const Icon(
                Icons.place_outlined,
                size: 16,
                color: AppColors.accentTeal,
              ),
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
            onTap: onContactTap,
          ),
          const SizedBox(height: 8),
          _LinkRow(
            label: 'GitHub',
            value: l10n.githubLinkLabel,
            onTap: onGitHubTap,
          ),
          const SizedBox(height: 8),
          _LinkRow(
            label: 'LinkedIn',
            value: l10n.linkedInLinkLabel,
            onTap: onLinkedInTap,
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

class StatsSection extends StatelessWidget {
  const StatsSection({
    super.key,
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
          child: GlassCard(
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

class FocusCards extends StatelessWidget {
  const FocusCards({
    super.key,
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
        final color = _toneToColor(card.tone);

        return SizedBox(
          width: width,
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_iconFor(card.icon), color: color),
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

  IconData _iconFor(FocusCardIcon icon) {
    switch (icon) {
      case FocusCardIcon.design:
        return Icons.design_services_outlined;
      case FocusCardIcon.performance:
        return Icons.flash_on_outlined;
      case FocusCardIcon.integrations:
        return Icons.hub_outlined;
    }
  }

  Color _toneToColor(FocusCardTone tone) {
    switch (tone) {
      case FocusCardTone.blue:
        return AppColors.accentBlue;
      case FocusCardTone.teal:
        return AppColors.accentTeal;
      case FocusCardTone.coral:
        return AppColors.accentCoral;
    }
  }
}

class SkillCloud extends StatelessWidget {
  const SkillCloud({
    super.key,
    required this.skills,
  });

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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

class TimelineSection extends StatelessWidget {
  const TimelineSection({
    super.key,
    required this.items,
  });

  final List<TimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
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

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.data,
    required this.onContactTap,
    required this.onGitHubTap,
    required this.onLinkedInTap,
  });

  final ProfileData data;
  final VoidCallback onContactTap;
  final VoidCallback onGitHubTap;
  final VoidCallback onLinkedInTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GlassCard(
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
                onTap: onContactTap,
              ),
              _ContactChip(
                icon: Icons.code_outlined,
                label: l10n.githubLinkLabel,
                onTap: onGitHubTap,
              ),
              _ContactChip(
                icon: Icons.business_center_outlined,
                label: l10n.linkedInLinkLabel,
                onTap: onLinkedInTap,
              ),
            ],
          ),
        ],
      ),
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
