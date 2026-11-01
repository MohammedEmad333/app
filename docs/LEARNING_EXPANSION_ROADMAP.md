# LingoKids — Learning Expansion Roadmap

Updated: 2026-11-01

## Verified existing functionality
- Standalone Grammar Lessons screen linked from the skill tree.
- Twenty grammar topics defined in `lib/features/grammar/grammar_lessons_screen.dart`, including explanations, examples, and two assessment questions.
- Grammar quiz flow, score calculation, Hive-backed progress and review prioritization.
- Vocabulary unit skill tree, XP, streaks, achievements, and spaced mistake review.

## This PR
- Add automated content integrity and score tests for the existing Grammar Academy.
- Update project documentation to avoid claiming the academy is absent.
- Do not introduce a second competing grammar catalog or screen.

## Next engineering tasks
- [x] PR #105 passed Flutter CI and platform smoke tests and merged into main.
- [ ] Run Flutter analyze and test for the new grammar search PR; fix any failing checks.
- [ ] Separate the existing hard-coded grammar topic catalog into a repository without changing existing progress identifiers.
- [x] Add live grammar topic search (title and explanation) without modifying saved progress keys.
- [x] Add A1/A2/B1-inspired learning bands and selectable level filtering without changing Hive keys.
- [ ] Validate CEFR mappings pedagogically and extend higher-level content.
- [x] Add mastery average best-score and total attempts using existing Hive keys.
- [x] Add recent practice average and regression-aware review using existing Hive histories.
- [x] Add regression tests for legacy Hive keys, persisted scores, duplicate catalog titles and stale catalog entries.
- [ ] Add versioned migrations if the grammar storage schema changes.
- [ ] Extend grammar practice with accessible keyboard and screen reader flows.
- [ ] Improve vocabulary spaced repetition using deterministic review scheduling tests.
- [ ] Add reading, listening and writing practice without duplicating existing lesson types.

## Quality gates
Do not merge without confirming the relevant CI checks. Verify Arabic RTL and English LTR, saved progress compatibility, offline content and accessibility. Delete merged branches.
