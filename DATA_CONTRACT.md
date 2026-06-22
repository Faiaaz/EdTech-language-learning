# EZ Trainz — Frontend → Backend Data Contract

EZ Trainz is a mobile language-learning app (Duolingo-style, for Japanese/Korean/German,
taught in Bengali). The Flutter frontend is built **UI-first**, so the screens already
prove exactly what data is needed. This document is derived from the actual client code.

## Status legend
- ✅ **Has model + JSON** (`lib/models/`) and a stubbed endpoint → backend just implements
- 🟡 **Hardcoded in UI** → needs a new API
- 🔴 **In-memory only** → needs persistence (lost on app close today)

## Conventions / constraints
- Integer IDs are **non-contiguous** (lesson ids in use: 1, 2, 3, 13, 14, 15, 16) — do **not** assume 1..n.
- Content is **multilingual**: Japanese (`jp`, `romaji`) + Bengali (`pronunciationBn`, `meaningBn`). Keep locale fields explicit.
- Programs observed: **JLC** (Japanese), **KLC** (Korean), **GLC** (German).

---

## 1. Course ✅  (`lib/models/course.dart`)
```json
{
  "id": 1,
  "title": "N5 Beginner",
  "description": "Introductory level Japanese course for absolute beginners.",
  "level": "N5",
  "createdAt": "2026-01-27T08:42:17.818Z",
  "updatedAt": "2026-01-27T08:42:17.818Z",
  "lessons": [ /* Lesson[] */ ]
}
```
> Suggest adding `programId` ("jlc"/"klc"/"glc") and `order`.

## 2. Lesson ✅  (`lib/models/lesson.dart`)
```json
{
  "id": 2,
  "courseId": 1,
  "title": "Lesson 2: Japanese Hi-Hello",
  "description": "Learn Japanese greetings and everyday phrases.",
  "content": { "body": "Master ohayou, konnichiwa...", "type": "text" },
  "createdAt": "2026-01-27T08:42:17.818Z",
  "updatedAt": "2026-01-27T08:42:17.818Z",
  "quizzes": [ /* Quiz[] */ ]
}
```
> Lessons in use: 1 Hero Number · 2 Hi-Hello · 3 Weekdays · 13 Akasatana · 14 Bornomala · 15 Dakuten · 16 Kichu Kotha.

## 3. Quiz ✅  (`lib/models/quiz.dart`)
```json
{ "id": 5, "lessonId": 2, "title": "Greetings Check", "passingScore": 80,
  "createdAt": "...", "updatedAt": "..." }
```

## 4. Lesson video 🟡  (`course_service.dart` → `_staticVideoUrls`, has a TODO)
Currently a hardcoded `lessonId → YouTube URL` map. Needs a signed-URL endpoint:
```
GET /lessons/{lessonId}/video →
{ "lessonId": 2, "provider": "youtube", "url": "https://...", "expiresAt": "..." }
```

---

## 5. Game content 🟡  (all hardcoded in lesson screen files)

Each lesson runs mini-games (listen MCQ, read MCQ, flashcards, match, rush, speak).
Content lives in Dart consts. Proposed: a game-items API per lesson.

### 5a. Time-greeting item (from `_TimeGreeting`)
| UI field | API field | Type | Example |
|---|---|---|---|
| id | id | int | 0 |
| jp | jp | string | おはようございます |
| romaji | romaji | string | ohayou gozaimasu |
| bnPron | pronunciationBn | string | ওহাইও গোজাইমাস |
| bnMeaning | meaningBn | string | শুভ সকাল |
| timeLabel | timeLabelBn | string | সকাল |
| icon/color | scene | enum | sunrise \| midday \| sunset \| night |

```json
{ "id": 0, "jp": "おはようございます", "romaji": "ohayou gozaimasu",
  "pronunciationBn": "ওহাইও গোজাইমাস", "meaningBn": "শুভ সকাল",
  "timeLabelBn": "সকাল", "scene": "sunrise" }
```

### 5b. Phrase item (from `_Phrase`)
| UI field | API field | Type | Example |
|---|---|---|---|
| jp | jp | string | ありがとう |
| romaji | romaji | string | arigatou |
| bnPronunciation | pronunciationBn | string | আরিগাতো |
| bn | meaningBn | string | ধন্যবাদ |

```json
{ "jp": "ありがとう", "romaji": "arigatou",
  "pronunciationBn": "আরিগাতো", "meaningBn": "ধন্যবাদ" }
```

### 5c. Game definition (config currently hardcoded — rounds, scoring)
| UI value | API field | Type | Example |
|---|---|---|---|
| game type | type | enum | listen_mcq \| read_mcq \| flashcard \| match \| rush \| speak |
| title text | titleBn | string | শুনে বলো — অডিও শুনে অর্থ বাছুন |
| _totalRounds | rounds | int | 8 |
| `_xp += 10` | xpPerCorrect | int | 10 |
| content pool | itemPool | enum | time_greetings \| phrases \| kana |

```json
{ "gameId": "hi_listen", "lessonId": 2, "type": "listen_mcq",
  "titleBn": "শুনে বলো — অডিও শুনে অর্থ বাছুন",
  "rounds": 8, "xpPerCorrect": 10, "itemPool": "time_greetings" }
```
> Suggested: `GET /lessons/{id}/games` → Game[] and `GET /lessons/{id}/items?pool=time_greetings`.

---

## 6. User progress / gamification 🔴  (in-memory only today)
Found across games: `xp`, `streak`, `bestStreak`, `correct`, `totalAttempts`,
`missed{jp→count}`, accuracy = correct/attempts. **None survives an app restart.**
```json
// POST /progress/attempt
{ "userId": "u_123", "lessonId": 2, "gameId": "hi_listen",
  "itemId": "0", "correct": true, "xpAwarded": 10, "ts": "..." }

// GET /users/{id}/progress →
{ "totalXp": 1240, "streak": 6, "bestStreak": 11, "lastActiveDate": "2026-06-16",
  "lessons": [ { "lessonId": 2, "completed": true, "accuracy": 0.92, "bestStreak": 9 } ] }
```
> **Streak rollover must be server-authoritative** (timezone-aware). Validate XP server-side.

## 7. SRS card  (`lib/services/sm2_srs_service.dart`, SM-2 algorithm — has toJson/fromJson, stored LOCAL only)
```json
{ "id": "あ", "label": "あ", "easeFactor": 2.5, "repetitions": 0,
  "intervalDays": 0, "nextReview": "2026-06-17T00:00:00.000Z" }
```
```
GET  /users/{id}/srs            → SrsCard[]  (pull due cards across devices)
PUT  /users/{id}/srs/{cardId}   → upsert after a review
```

## 8. Pronunciation result 🟡  (`lib/services/jlc_stt.dart` → `JlcSttResult`)
Client today: `recognizedWords`, `confidence`, `finalResult`, and **ElevenLabs/Scribe
keys shipped in the app (security risk)**. Move scoring server-side:
```json
// POST /pronunciation/score   (multipart: audio + targetPhrase) →
{ "targetPhrase": "おはようございます", "overallScore": 0.87,
  "recognizedWords": "おはよう ございます",
  "words": [ { "word": "おはよう", "confidence": 0.94 },
             { "word": "ございます", "confidence": 0.80 } ] }
```

---

## Summary

| Area | Source | Status | Backend action |
|---|---|---|---|
| Course / Lesson / Quiz | `models/*` | ✅ models + stubbed endpoints | Implement `GET /courses`, `/courses/{id}/lessons`, `/lessons/{id}` |
| Lesson video | `course_service.dart` | 🟡 hardcoded map | Signed-URL endpoint |
| Game content (greetings/phrases/kana) | lesson screens | 🟡 hardcoded | `GET /lessons/{id}/games` + `/items` |
| Game config (rounds/XP) | lesson screens | 🟡 hardcoded | Include in game definition |
| Progress / XP / streak | game state | 🔴 in-memory | `POST /progress/attempt`, `GET /users/{id}/progress` |
| SRS schedule | `sm2_srs_service.dart` | 🔴 local only | SRS sync endpoints |
| Pronunciation scoring | `jlc_stt.dart` | 🟡 client + exposed keys | Server-side `/pronunciation/score` proxy |

**First three for the backend dev:** (1) implement the course/lesson endpoints already
drafted (commented) in `course_service.dart`; (2) persist progress/streak/SRS server-side
— all in-memory today; (3) move the ElevenLabs/Scribe keys off the client.
