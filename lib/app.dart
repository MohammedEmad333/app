import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/home/skill_tree_screen.dart';
import 'features/progress/progress_cubit.dart';
import 'services/storage_service.dart';

class LingoKidsApp extends StatelessWidget {
  const LingoKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgressCubit(StorageService.instance),
      child: MaterialApp(
        title: 'LingoKids',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SkillTreeScreen(),
      ),
    );
  }
}
