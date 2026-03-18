import 'package:flutter/widgets.dart';

export 'turnstile_interface.dart';

import 'turnstile_interface.dart';
import 'turnstile_stub.dart' if (dart.library.html) 'turnstile_web.dart'
    as impl;

TurnstileController createTurnstileController({
  required String siteKey,
  required bool isLocalBypass,
}) {
  return impl.createTurnstileController(
    siteKey: siteKey,
    isLocalBypass: isLocalBypass,
  );
}

Widget buildTurnstileView({
  required TurnstileController controller,
}) {
  return impl.buildTurnstileView(controller: controller);
}
