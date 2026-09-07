import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/models/user_progress.dart';
import 'features/home/skill_tree_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/progress/progress_cubit.dart';
import 'services/storage_service.dart';

class LingoKidsApp extends StatelessWidget {
  const LingoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgressCubit(StorageService.instance),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // The interface is Arabic and lays out right-to-left; the English
        // learning content stays LTR within its own widgets.
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const _Gate(),
      ),
    );
  }
}

/// Shows onboarding until the child has entered their name, then the map.
class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, UserProgress>(
      buildWhen: (prev, curr) => prev.hasOnboarded != curr.hasOnboarded,
      builder: (context, progress) => progress.hasOnboarded
          ? const SkillTreeScreen()
          : const OnboardingScreen(),
    );
  }
}
