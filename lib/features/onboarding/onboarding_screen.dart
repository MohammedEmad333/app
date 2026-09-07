import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pop_button.dart';
import '../progress/progress_cubit.dart';

/// First-launch screen: the child meets the owl mascot and enters their name.
/// Shown until a name is saved, after which the map is the home screen.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bob.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _ready => _controller.text.trim().isNotEmpty;

  Future<void> _start() async {
    if (!_ready) return;
    await context.read<ProgressCubit>().setName(_controller.text);
    // The app's Gate rebuilds on the new name and shows the map.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _bob,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, -8 * _bob.value),
                    child: child,
                  ),
                  child: const Text('🦉', style: TextStyle(fontSize: 120)),
                ),
                const SizedBox(height: 16),
                Text(AppStrings.onboardingTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text(AppStrings.onboardingSubtitle,
                    style: AppTextStyles.body.copyWith(color: Colors.white)),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _start(),
                    maxLength: 20,
                    style: AppTextStyles.title,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: AppStrings.nameHint,
                      hintStyle: AppTextStyles.body
                          .copyWith(color: AppColors.disabledText),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                PopButton(
                  label: AppStrings.onboardingStart,
                  color: Colors.white,
                  shadowColor: const Color(0xFFDDDDDD),
                  textColor: AppColors.primary,
                  enabled: _ready,
                  onPressed: _ready ? _start : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
