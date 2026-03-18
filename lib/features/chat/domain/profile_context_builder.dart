import 'package:flutter/widgets.dart';

class ProfileContextLabels {
  const ProfileContextLabels({
    required this.name,
    required this.role,
    required this.location,
    required this.bio,
    required this.contact,
    required this.stats,
    required this.internalNotes,
  });

  final String name;
  final String role;
  final String location;
  final String bio;
  final String contact;
  final String stats;
  final String internalNotes;
}

abstract interface class ProfileContextBuilder {
  String build({
    required Locale locale,
    required ProfileContextLabels labels,
  });
}
