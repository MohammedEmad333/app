/// Arabic UI strings for the app chrome. The English words the child is
/// learning always stay in English (they live in the content JSON and in each
/// question's options / word bank / answer); only the surrounding interface,
/// instructions and feedback are translated here.
///
/// Arabic-Indic digits are used for counts so the interface reads naturally
/// for young Arab learners.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'LingoKids';
  static const String appTagline = 'تعلّم الإنجليزية باللعب';

  // Onboarding
  static const String onboardingTitle = 'أهلاً بك! أنا البومة لينغو 🦉';
  static const String onboardingSubtitle = 'ما اسمك؟';
  static const String nameHint = 'اكتب اسمك هنا';
  static const String onboardingStart = 'هيّا نبدأ!';
  static String greeting(String name) => 'مرحباً، $name 👋';

  // Home / map
  static const String profileTooltip = 'ملفي';
  static const String noHeartsLeft = 'لا توجد قلوب! ستعود مع الوقت ❤️';
  static const String unitLocked = 'أكمل الوحدة السابقة لفتح هذه الوحدة 🔒';
  static const String unitLockedBanner = 'مقفلة — أكمل الوحدة السابقة';

  // Difficulty tiers (by unit)
  static String difficultyLabel(int tier) {
    switch (tier) {
      case 1:
        return 'سهل';
      case 2:
        return 'متوسط';
      case 3:
        return 'صعب';
      default:
        return 'متقدّم';
    }
  }

  // Daily goal
  static const String dailyGoal = 'الهدف اليومي';
  static String dailyGoalRemaining(int remaining, int xp, int goal) =>
      'باقي ${_ar(remaining)} نقطة (${_ar(xp)}/${_ar(goal)})';
  static const String dailyGoalDone = 'أنجزت هدف اليوم — أحسنت! 🎉';

  // Lesson runner
  static const String check = 'تحقّق';
  static const String continueLabel = 'متابعة';
  static const String gotIt = 'فهمت';
  static const String practice = 'تدريب';
  static const String review = 'مراجعة';

  // Review mistakes
  static const String reviewTitle = 'مراجعة الأخطاء';
  static const String reviewBannerTitle = 'راجع أخطاءك';
  static String reviewBannerSubtitle(int n) => '${_ar(n)} كلمة تحتاج مراجعة';
  static String reviewButton(int n) => 'راجع أخطاءك (${_ar(n)})';
  static const String reviewEmpty = 'لا أخطاء لمراجعتها الآن 🎉';
  static const String correctTitle = 'أحسنت! 🎉';
  static const String wrongTitle = 'ليست صحيحة';
  static const String correctAnswerLabel = 'الإجابة الصحيحة:';

  static const String quitTitle = 'إنهاء الدرس؟';
  static const String quitBody = 'لن يتم حفظ تقدّمك في هذا الدرس.';
  static const String stay = 'البقاء';
  static const String quit = 'خروج';

  static const String outOfHeartsTitle = 'نفدت القلوب!';
  static const String outOfHeartsBody =
      'انتهت قلوبك. أعد ملأها لتكمل التدريب!';
  static const String leave = 'مغادرة';
  static const String refill = 'إعادة الملء';

  // Completion
  static const String lessonComplete = 'أكملت الدرس!';
  static const String practiceDone = 'انتهى التدريب!';
  static const String tapChest = 'اضغط الصندوق لفتح مكافأتك';
  static const String amazingWork = 'عمل رائع! 🌟';
  static const String xpLabel = '⚡ نقاط';
  static const String accuracyLabel = '🎯 الدقة';

  // Profile
  static const String profileTitle = 'ملفي الشخصي';
  static String levelLabel(int n) => 'المستوى ${_ar(n)}';
  static String xpToNextLevel(int into) =>
      '${_ar(into)} / ١٠٠ نقطة للمستوى التالي';
  static const String statStreak = 'أيام متتالية';
  static const String statXp = 'مجموع النقاط';
  static const String statHearts = 'القلوب';
  static const String statLessons = 'دروس مكتملة';
  static const String achievements = 'الإنجازات';
  static String achievementsUnlocked(int unlocked, int total) =>
      'فتحت ${_ar(unlocked)} من ${_ar(total)}';
  static const String practiceALesson = 'تدرّب على درس';
  static const String resetProgress = 'إعادة ضبط التقدّم';
  static const String resetTitle = 'إعادة ضبط التقدّم؟';
  static const String resetBody =
      'سيؤدي هذا إلى مسح نقاطك وأيامك المتتالية ودروسك المكتملة. لا يمكن التراجع.';
  static const String cancel = 'إلغاء';
  static const String reset = 'إعادة الضبط';
  static const String resetDone = 'تمت إعادة الضبط. بداية جديدة! 🌱';

  // Accessibility
  static String heartsRemaining(int n) => 'باقي ${_ar(n)} قلوب';

  /// Converts Western digits in a number to Arabic-Indic digits.
  static String _ar(int value) {
    const western = '0123456789';
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final ch in value.toString().split('')) {
      final i = western.indexOf(ch);
      buffer.write(i >= 0 ? eastern[i] : ch);
    }
    return buffer.toString();
  }

  /// Public helper for widgets that need Arabic-Indic digits (e.g. counters).
  static String arDigits(int value) => _ar(value);
}
