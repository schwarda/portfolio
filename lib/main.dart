import 'package:flutter/widgets.dart';

import 'app/app_dependencies.dart';
import 'app/portfolio_app.dart';

export 'app/portfolio_app.dart';

void main() {
  runApp(
    PortfolioApp(
      dependencies: AppDependencies.create(),
    ),
  );
}
