import 'package:flutter/widgets.dart';

import '../../portfolio/domain/portfolio_content_repository.dart';
import '../domain/profile_context_builder.dart';

class LocalizedProfileContextBuilder implements ProfileContextBuilder {
  const LocalizedProfileContextBuilder({
    required PortfolioContentRepository contentRepository,
  }) : _contentRepository = contentRepository;

  final PortfolioContentRepository _contentRepository;

  @override
  String build({
    required Locale locale,
    required ProfileContextLabels labels,
  }) {
    final content = _contentRepository.contentFor(locale);
    final profile = content.profile;
    final stats =
        content.stats.map((item) => '${item.label}: ${item.value}').join('; ');
    final internalNotes = content.internalProfileNotes.join('; ');

    return [
      '${labels.name}: ${profile.name} ${profile.surname}',
      '${labels.role}: ${profile.title}',
      '${labels.location}: ${profile.location}',
      '${labels.bio}: ${profile.about}',
      '${labels.contact}: email ${profile.email}, GitHub ${profile.github}, LinkedIn ${profile.linkedIn}',
      '${labels.stats}: $stats',
      '${labels.internalNotes}: $internalNotes',
    ].join('\n');
  }
}
