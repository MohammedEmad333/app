# LingoKids — Learning Expansion Roadmap

Status: Foundation content and loader implemented on feature branch; UI integration pending.

## Baseline
Flutter + flutter_bloc + Hive; existing unit skill tree, question runner, XP, streaks, achievements and mistake review. Do not replace or duplicate these systems.

## Phase 1 — Grammar Academy
- [x] Independent grammar topic schema and JSON loader
- [x] Initial A1 topics with explanations, examples and multiple-choice assessments
- [ ] Grammar topic list and detail screens
- [ ] Dedicated grammar quiz flow, answer feedback and completion
- [ ] Persist grammar mastery independently of unit completion
- [ ] Automated model, loader and widget tests

## Phase 2 — Vocabulary and spaced review
- [ ] Vocabulary cards extracted from canonical lesson content
- [ ] Persist per-item review state and due dates in Hive
- [ ] Review scheduling with deterministic tests
- [ ] Offline-first UI and error handling

## Phase 3 — Skills
- [ ] Reading comprehension studio
- [ ] Listening studio
- [ ] Writing coach
- [ ] Pronunciation lab with explicit microphone consent

## Phase 4 — Personalization
- [ ] Placement assessment
- [ ] Adaptive practice
- [ ] Skill mastery analytics
- [ ] Optional AI conversation with child-safety and privacy review

## Quality gates
Run flutter analyze and flutter test; verify Arabic RTL and English LTR content, offline assets, accessibility and navigation. No merge before CI passes. One cohesive PR per tested feature slice. Delete merged feature branches.

## Content contract
assets/data/grammar_topics.json is a list of unique topic IDs. Each topic contains id, title, level, explanation, examples and questions. Each question contains prompt, options (at least two), correctIndex (zero-based) and explanation. No progress is written by the catalog loader.
