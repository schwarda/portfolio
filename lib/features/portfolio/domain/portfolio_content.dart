enum FocusCardIcon {
  design,
  performance,
  integrations,
}

enum FocusCardTone {
  blue,
  teal,
  coral,
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
    required this.linkedIn,
  });

  final String name;
  final String surname;
  final String initials;
  final String title;
  final String location;
  final String about;
  final String email;
  final String github;
  final String linkedIn;
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
    required this.tone,
  });

  final FocusCardIcon icon;
  final String title;
  final String description;
  final FocusCardTone tone;
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

class PortfolioContent {
  const PortfolioContent({
    required this.profile,
    required this.stats,
    required this.focusCards,
    required this.skillTags,
    required this.timelineItems,
    required this.internalProfileNotes,
  });

  final ProfileData profile;
  final List<StatItem> stats;
  final List<FocusCardData> focusCards;
  final List<String> skillTags;
  final List<TimelineItem> timelineItems;
  final List<String> internalProfileNotes;
}
