// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'link_opener_interface.dart';

class _WebLinkOpener implements LinkOpener {
  @override
  Future<bool> downloadPath(
    String path, {
    String? suggestedFileName,
  }) async {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty) {
      return false;
    }

    final anchor = html.AnchorElement(href: normalizedPath)
      ..target = '_blank'
      ..rel = 'noopener noreferrer';
    if ((suggestedFileName ?? '').trim().isNotEmpty) {
      anchor.download = suggestedFileName!.trim();
    }
    anchor.click();
    return true;
  }

  @override
  Future<bool> openExternalUrl(
    String url, {
    String target = '_blank',
  }) async {
    final normalizedUrl = url.trim();
    if (normalizedUrl.isEmpty) {
      return false;
    }

    html.window.open(normalizedUrl, target);
    return true;
  }

  @override
  Future<bool> openMailto({
    required String email,
    String? subject,
    String? body,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return false;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: normalizedEmail,
      queryParameters: <String, String>{
        if ((subject ?? '').trim().isNotEmpty) 'subject': subject!.trim(),
        if ((body ?? '').trim().isNotEmpty) 'body': body!.trim(),
      },
    );

    html.window.location.assign(uri.toString());
    return true;
  }
}

LinkOpener createLinkOpener() => _WebLinkOpener();
