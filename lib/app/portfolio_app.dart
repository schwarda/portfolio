import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/portfolio/presentation/pages/about_me_page.dart';
import 'app_dependencies.dart';
import 'controllers/app_locale_controller.dart';
import 'localization/app_localizations.dart';
import '../core/theme/app_theme.dart';

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({
    super.key,
    required this.dependencies,
  });

  final AppDependencies dependencies;

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  late final AppLocaleController _localeController = AppLocaleController(
    WidgetsBinding.instance.platformDispatcher.locale,
  );

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) =>
              AppLocalizations.of(context).browserTitle,
          locale: _localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.build(),
          home: AppLocaleScope(
            controller: _localeController,
            child: AboutMePage(
              portfolioContentRepository:
                  widget.dependencies.portfolioContentRepository,
              portfolioActionController:
                  widget.dependencies.portfolioActionController,
              chatControllerFactory: widget.dependencies.createChatController,
            ),
          ),
        );
      },
    );
  }
}
