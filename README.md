# 🦉 LingoKids — تعلّم الإنجليزية باللعب

A cross-platform (iOS / Android / Web / Desktop) mobile app that teaches
**English to Arab kids**, heavily inspired by Duolingo's gamified learning
mechanics. Built with **Flutter** + **flutter_bloc**.

> **Bilingual by design.** The interface is fully **Arabic and right-to-left**
> (via `flutter_localizations`, Arabic-Indic digits, and the **bundled** Cairo
> font — SIL OFL 1.1, so the Arabic UI renders offline), while
> the **words being taught stay in English** — options, sentence chips, audio
> and speech targets. English sentences are always assembled left-to-right even
> inside the RTL layout.

<p align="center"><em>Skill tree → Lesson runner → Celebration 🎉</em></p>

---

## ✨ Features

### 1. Skill Tree / Map screen
- A winding path of **lesson nodes** grouped under units.
- Node status indicators:
  - 🔒 **Locked** — greyed-out padlock
  - 🟢 **Current** — pulsing animated ring
  - ⭐ **Completed** — golden star
- Live **stats header**: 🔥 streak · ⚡ XP · ❤️ hearts.

### 2. Lesson Runner Engine (Quiz Engine)
- Step-by-step flow with a **progress bar** and a **hearts/lives counter** (starts at 5).
- Four interactive question widget types:
  | Type | Interaction |
  |------|-------------|
  | **Image Matching** | Visual 4-grid option selection |
  | **Word Jumble / Sentence Builder** | Tap word chips to assemble a phrase |
  | **Audio Listening** | Play audio (TTS) and pick the matching answer |
  | **Speech Recognition** | Tap the mic, speak, and get validated |
- Immediate feedback **bottom sheet**: green + success sound when correct,
  red + explanation + heart loss when wrong.

### 3. Gamification & Rewards
- **XP** awarded on lesson completion, with a **level** every 100 XP.
- **Streak** tracking (daily activity counter, resets if a day is missed).
- **Hearts** that deplete on mistakes and **regenerate over time**.
- **Daily goal ring** — a per-day XP target shown on the map and profile.
- **Achievements** — 10 unlockable badges (first lesson, streaks, XP milestones,
  units cleared, champion…) derived live from progress.
- **Practice mode** — replay any completed lesson with no hearts at stake for
  bonus XP (from a completed node, or "Practice a lesson" on the profile).
- **Review mistakes** — every wrong answer is flagged; a review banner on the
  map (and a profile button) builds a no-stakes lesson from the missed
  questions, and answering one correctly removes it from the review list.
- **Profile screen** — level, daily goal, lifetime stats, badges, and reset.
- **Sound + haptics** — bundled tone SFX for correct/wrong/celebrate plus
  vibration feedback on answers.
- **Lesson Completion screen** with **confetti** and an **openable reward chest**.

### 4. Kid-friendly UI/UX
- Colorful design system, **3D "pop" buttons** (Duolingo style), large touch
  targets, bold rounded typography (Nunito), and playful micro-animations.

---

## 🏗️ Architecture

```
lib/
├── main.dart                       # Entry point (init Hive, run app)
├── app.dart                        # MaterialApp + global ProgressCubit
├── core/
│   ├── theme/                      # Colors, text styles, ThemeData
│   └── widgets/                    # PopButton, HeartsIndicator, LessonProgressBar
├── data/
│   ├── models/                     # Unit, Lesson, Question, UserProgress
│   └── repositories/               # ContentRepository (loads seed JSON)
├── services/
│   ├── storage_service.dart        # Hive persistence + streak/hearts rules
│   ├── audio_service.dart          # audioplayers sound effects
│   ├── tts_service.dart            # flutter_tts pronunciation
│   └── speech_service.dart         # speech_to_text validation
└── features/
    ├── home/                       # Skill tree + nodes + stats header
    ├── lesson/                     # Lesson runner, cubit, question widgets
    └── progress/                   # ProgressCubit (global XP/streak/hearts)

assets/
└── data/units.json                 # Seed: Unit 1 — Animals & Greetings (3 lessons)
```

- **State management:** `flutter_bloc` (Cubits) — `ProgressCubit` (global) and
  `LessonCubit` (per-lesson runner).
- **Local storage:** `hive` / `hive_flutter` — progress, streaks, XP, hearts,
  completed lessons (stored as a plain map, no codegen required).
- **Animations:** `confetti` package (celebration) + Lottie-ready asset slot.
- **Audio / speech:** `audioplayers`, `flutter_tts`, `speech_to_text`.

---

## 📊 Content schema

Units → Lessons → Questions are defined in `assets/data/units.json` and parsed
by the model classes. Seeded with **24 units, 72 lessons and 345 questions**
spanning all four question types, with a **difficulty that ramps up** as the
child advances (each unit carries a `difficulty` tier shown on its banner):

| Unit | Theme | Difficulty |
|------|-------|-----------|
| 1 | Animals & Greetings | سهل (easy) |
| 2 | Numbers & Colors | سهل (easy) |
| 3 | Food & Drinks | متوسط (medium) |
| 4 | Family & Home | متوسط (medium) |
| 5 | Actions & Feelings | صعب (hard) |
| 6 | Sentences & Conversations | صعب (hard) |
| 7 | Time & Weather | متقدّم (advanced) |
| 8 | School & Learning | متقدّم (advanced) |
| 9 | Body & Health | متقدّم (advanced) |
| 10 | Around Town | متقدّم (advanced) |
| 11 | Nature World | متقدّم (advanced) |
| 12 | Hobbies & Sports | متقدّم (advanced) |
| 13 | Days & Seasons | متقدّم (advanced) |
| 14 | Shopping & Market | متقدّم (advanced) |
| 15 | Stories & Tales | خبير (expert) |
| 16 | Science & Space | خبير (expert) |
| 17 | Countries & Cultures | بطل (champion) |
| 18 | Advanced Conversations | بطل (champion) |
| 19 | Technology | خبير (expert) |
| 20 | Feelings & Friendship | بطل (champion) |
| 21 | In the Kitchen | خبير (expert) |
| 22 | Travel & Adventure | بطل (champion) |
| 23 | Money & Saving | خبير (expert) |
| 24 | Our Planet & Environment | بطل (champion) |

The `difficulty` tier runs from **1 to 6**, each with its own Arabic label and
dot count on the unit banner: سهل (easy) · متوسط (medium) · صعب (hard) · متقدّم
(advanced) · خبير (expert) · بطل (champion).

Early units teach single words with short 4-word sentences; later units move to
full sentences and questions — longer word-jumbles (up to 8 words with extra
decoy chips), phrase-level audio/image choices, paragraph-length reading and
opinion prompts, and 5 questions per lesson with higher XP. **Units unlock one after another** — a unit stays locked (dimmed,
with a lock badge) until the previous unit is fully completed, so the harder
content is earned. Add new units or lessons by appending to the JSON — no code
changes needed.

---

## 🚀 Getting started

> Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install)
> (stable channel, Dart ≥ 3.3).

```bash
# 1. Generate the platform runners (android/ios/web/...) for this source tree.
#    This does NOT overwrite lib/, pubspec.yaml, or assets/.
flutter create .

# 2. Install dependencies
flutter pub get

# 3. Run on your device / emulator / browser
flutter run                 # attached device
flutter run -d chrome       # web
```

Run the tests with:

```bash
flutter test
```

### 🔐 Permissions for Speech Recognition

`speech_to_text` needs microphone permission. After `flutter create .`, add:

**Android** — `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We use the microphone so kids can practice speaking English.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We use speech recognition to check pronunciation.</string>
```

The speech question degrades gracefully (offers a tap-to-continue fallback) if
the microphone is unavailable, so the app remains fully playable everywhere.

### 🔊 Optional media

Sound effects (`assets/audio/`) and Lottie files (`assets/lottie/`) are
optional — see the READMEs in those folders. The app ships working audio via
device TTS and a code-driven confetti celebration, so nothing extra is required.

---

## 🧩 Extending the app
- **Add a lesson/unit:** append to `assets/data/units.json`.
- **Add a question type:** add a value to `QuestionType`, a widget implementing
  the `QuestionWidget` contract, and a branch in `buildQuestionWidget`.
- **Swap emoji for artwork:** set `imageAsset` on options and render
  `Image.asset` in the question widgets.
