import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pop_button.dart';
import '../../services/audio_service.dart';

/// Celebration screen shown when a lesson is completed: confetti, an openable
/// reward chest, and the XP earned.
class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({
    super.key,
    required this.xpEarned,
    required this.accuracyPercent,
    this.practice = false,
  });

  final int xpEarned;
  final int accuracyPercent;
  final bool practice;

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _chestController;
  bool _chestOpen = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _openChest() {
    if (_chestOpen) return;
    setState(() => _chestOpen = true);
    _chestController.forward();
    _confetti.play();
    AudioService.instance.celebrate();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _chestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.practice ? 'Practice Done!' : 'Lesson Complete!',
                      style:
                          AppTextStyles.display.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    _chestOpen
                        ? 'Amazing work! 🌟'
                        : 'Tap the chest to open your reward',
                    style:
                        AppTextStyles.body.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _chest(),
                  const SizedBox(height: 40),
                  if (_chestOpen) _stats(),
                  const Spacer(),
                  if (_chestOpen)
                    PopButton(
                      label: 'Continue',
                      color: Colors.white,
                      shadowColor: const Color(0xFFDDDDDD),
                      textColor: AppColors.primary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.25,
              colors: const [
                AppColors.yellow,
                AppColors.blue,
                AppColors.purple,
                AppColors.orange,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chest() {
    return GestureDetector(
      onTap: _openChest,
      child: AnimatedBuilder(
        animation: _chestController,
        builder: (context, child) {
          final wobble = sin(_chestController.value * pi * 3) * 0.05;
          return Transform.rotate(
            angle: _chestOpen ? 0 : wobble,
            child: AnimatedScale(
              scale: _chestOpen ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Text(
                _chestOpen ? '🎁' : '🧰',
                style: const TextStyle(fontSize: 140),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statCard('⚡ XP', '+${widget.xpEarned}', AppColors.yellow),
        const SizedBox(width: 16),
        _statCard('🎯 Accuracy', '${widget.accuracyPercent}%', AppColors.blue),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.heading.copyWith(color: color)),
        ],
      ),
    );
  }
}
