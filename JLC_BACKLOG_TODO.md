# EZ Trainz — JLC Backlog · Status & To-Do

Audit of [`EZ_Trainz_JLC_Backlog.md`](file:///Users/fahimfaiaz/Downloads/EZ_Trainz_JLC_Backlog.md) against the current codebase (branch `perf/mediaquery-granular-accessors`).

**Legend:** ✅ done · 🟡 partial · ⬜ not done · ❓ decision/QA (not a code task)

Status assessed from code only — items marked 🧪/needs-review require running the app or a content pass to confirm.

---

## ✅ Done

- [x] **Each Practice game = exactly 3 questions** — `kLessonPracticeQuestions = 3` in [lesson_practice_config.dart:4](lib/utils/lesson_practice_config.dart#L4), wired via `sessionRounds` in [hiragana_lesson1_screen.dart:588](lib/view/hiragana_lesson1_screen.dart#L588) and [n5_lesson_video_screens.dart:46](lib/view/n5_lesson_video_screens.dart#L46).
- [x] **JLC = 4 cards (Language · Culture · Career · Wisdom)** — [jlc_home_screen.dart:177](lib/view/jlc_home_screen.dart#L177). Culture/Career/Wisdom → coming-soon.
- [x] **Language page layout (video explainer → level scroll → Practice/Challenge)** — [jlc_language_screen.dart:100](lib/view/jlc_language_screen.dart#L100). Note: the Japan video explainer is currently a coming-soon placeholder, not a real video.
- [x] **Show N5 lesson outline / full list** — [course_list_screen.dart:934](lib/view/course_list_screen.dart#L934) lists every lesson + the kana section.
- [x] **Greetings: Practice + Challenge = phrase match** — `ফ্রেজ ম্যাচ` at [n5_lesson_video_screens.dart:171](lib/view/n5_lesson_video_screens.dart#L171).
- [x] **পড়ে বলো: preserve office-context trick logic** — office → `Ohayo gozaimasu` at [n5_hi_hello_lesson_screen.dart:231](lib/view/n5_hi_hello_lesson_screen.dart#L231).

---

## 🟡 Partial — started, needs finishing

- [ ] **হিরো নাম্বার ১ landing layout** — video on top ✅, Practice grid ✅, Challenge → সাজাও ✅; **missing:** below-video Reading/Writing/Listening/Speaking labels and the **horizontal score bar** ([hiragana_lesson1_screen.dart:433](lib/view/hiragana_lesson1_screen.dart#L433)).
- [ ] **Keep "বলতে পারো"; omit Match Master** — both still exist in the games list ([n5_hero_number1_lesson_screen.dart:234](lib/view/n5_hero_number1_lesson_screen.dart#L234)); Match Master is not surfaced on the landing but isn't removed.
- [ ] **Relaxed, vibrant Practice UI** — vibrant gradient cards ✅ ([lesson_practice_game_cards.dart:175](lib/widgets/lesson_practice_game_cards.dart#L175)); **missing:** emoji in titles + calming wave/water/ripple/flower motion.
- [ ] **Remove the progress bar** — removed in hero-number game, **still present in Greetings** (`LinearProgressIndicator` at [n5_hi_hello_lesson_screen.dart:491](lib/view/n5_hi_hello_lesson_screen.dart#L491), 1382, 1668).
- [ ] **Greetings こんにちは card design** — konnichiwa + romaji ✅, speaker icon ✅, "বাংলা অর্থ কী?" ✅ ([n5_hi_hello_lesson_screen.dart:2206](lib/view/n5_hi_hello_lesson_screen.dart#L2206)); **verify** exact styling: yellow circle + blue speaker, larger meaning font.
- [ ] **Greetings option cards: time-of-day image on right** — uses `wb_sunny` / `wb_twilight` icons ([n5_hi_hello_lesson_screen.dart:166](lib/view/n5_hi_hello_lesson_screen.dart#L166)); **missing:** full 🌅☀️🌇🌙 morning/noon/evening/night image set.
- [ ] **Module Challenge: mixed questions, faster = more points, leaderboard** — Speed Boss + scoring/timer exist; **no leaderboard wired** into the module challenge.
- [ ] **সাজাও Challenge is timed** — `Stopwatch` + `সময়:` display exist ([n5_hero_number1_lesson_screen.dart:1257](lib/view/n5_hero_number1_lesson_screen.dart#L1257)); **missing:** lowest-time saved to record + leaderboard.

---

## ⬜ To-do — not started

- [ ] **Remove the "শুনুন" (listen) audio prompt from Lesson 1** — still present (`সব শুনুন` / `ভুলগুলি শুনুন` at [n5_hero_number1_lesson_screen.dart:4476](lib/view/n5_hero_number1_lesson_screen.dart#L4476)).
- [ ] **N5 landing: only first 3 topics accessible; lock the rest** — no lock logic; all lessons tappable ([course_list_screen.dart:934](lib/view/course_list_screen.dart#L934)).
- [ ] **N5 landing: each topic = thumbnail video** — tiles are text + play icon, not video thumbnails (vertical scroll ✅).
- [ ] **N5 landing: hide Lessons 2, 3, …** — all 7 lessons shown.
- [ ] **Practice: replace text labels with icon buttons** — underline-style icon grid, selected icon highlighted (current cards are icon + text).
- [ ] **Practice: completion state on icons** — blue tick after finishing a game; underline while inside.
- [ ] **Practice: add scroll arrow to the practice bar.**
- [ ] **Practice: remove the second line from the top** — confirm location and remove.
- [ ] **Answer feedback — wrong:** reduce shake intensity; highlight only the card border in yellow; **Doyo (Pengu) popup with hands crossed** (no Pengu popup in the lesson game screens).
- [ ] **Answer feedback — right:** blue Doyo (Pengu) popup with thumbs up.
- [ ] **Answer feedback — option text alignment:** shift toward center-right.
- [ ] **পড়ে বলো: omit the trick-question briefcase icon** — `business_center_rounded` still present ([n5_hi_hello_lesson_screen.dart:232](lib/view/n5_hi_hello_lesson_screen.dart#L232)).
- [ ] **পড়ে বলো: shorten the question text** — scene strings are long ([n5_hi_hello_lesson_screen.dart:231](lib/view/n5_hi_hello_lesson_screen.dart#L231)).
- [ ] **সাজাও audio** — blocked by the voice-options decision below.

---

## ❓ Decisions needed (gate other work)

- [ ] **Font & colour scheme for Q&A** — yellow-on-black question / blue-on-yellow answer proposal; needs final call + legibility check (Bengali + romaji).
- [ ] **সাজাও voice options** — recorded talents, TTS presets, or difficulty modes? Blocks সাজাও audio.

---

## 🧪 QA pass — N4 tester (after the build items land)

- [ ] Content rule: zero hiragana in Lesson 1; all text Bengali + romaji
- [ ] Romaji accuracy across every card
- [ ] Bengali translation accuracy
- [ ] Greeting → time-of-day image mapping correct
- [ ] পড়ে বলো office-context trick behaves as intended
- [ ] Feedback states correct on every game (right = blue/thumbs-up, wrong = yellow border/hands-crossed)
- [ ] Completion ticks appear after each game
- [ ] 3-question rule holds on every Practice game
- [ ] Access logic: only first 3 topics open; Lessons 2–3 hidden

> **Note:** "No hiragana in Lesson 1" couldn't be confirmed by code reading — it needs a content pass through every Lesson 1 screen/card/question.
