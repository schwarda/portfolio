import 'package:flutter/widgets.dart';

import 'portfolio_content.dart';

abstract interface class PortfolioContentRepository {
  PortfolioContent contentFor(Locale locale);
}
