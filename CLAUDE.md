# Vizancia - AI Learning App

## Overview
Vizancia is an iOS app that teaches AI literacy through gamified lessons, quizzes, and mini-games. Positioned as "the Duolingo of AI." Built with SwiftUI + SwiftData, no backend dependencies. Targeting kids 8-13 and young learners.

## Architecture

### Tech Stack
- **UI**: SwiftUI (iOS 17+)
- **Data**: SwiftData (on-device persistence)
- **No backend**: Everything runs locally. No API calls, no auth, no network dependencies.
- **No third-party SDKs**: Zero external dependencies.

### Project Structure
```
Vizancia/
├── App/
│   ├── VizanciaApp.swift      # @main entry, SwiftData container
│   └── ContentView.swift       # TabView (Home, Learn, Games, Progress)
├── Models/
│   ├── User.swift              # UserProfile @Model (SwiftData)
│   ├── Question.swift          # Question, LessonData, CategoryData, GameType, etc.
│   └── Achievement.swift       # AchievementData with conditions + progressInfo
├── Data/
│   ├── LessonContentProvider.swift  # Central content registry (16 categories)
│   ├── CategoryContent1-16.swift    # 16 categories, ~576 questions
│   └── FunFacts.swift               # 30 AI fun facts (shown inline, once per lesson)
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift           # Dashboard: greeting, continue, daily goal, quick play
│   │   ├── LearnView.swift          # Category browser: filter chips, full-width cards, Today's Pick
│   │   └── CategoryDetailView.swift # Lesson list within a category
│   ├── Lesson/
│   │   ├── LessonView.swift         # Quiz engine: intro, questions, combos, spaced repetition, mid-lesson save
│   │   ├── LessonCompleteView.swift # Results: stars, XP counting animation, confetti, level-up
│   │   ├── QuestionViews.swift      # All 6 question type views + OptionButton (with animations)
│   │   ├── PracticeMistakesView.swift # Review missed questions
│   │   └── DailyChallengeView.swift  # Daily question for bonus XP
│   ├── Games/
│   │   ├── GamesHubView.swift       # Game list (11 games)
│   │   ├── SpeedRoundGame.swift     # 60-second rapid-fire quiz
│   │   ├── AIPairsGame.swift        # Memory card matching + quiz hybrid
│   │   ├── BuzzwordBusterGame.swift # Real vs fake AI terms
│   │   ├── JargonMatchGame.swift    # 30-second term-to-definition speed game
│   │   ├── AITimelineGame.swift     # Reorder AI milestones chronologically
│   │   ├── FactOrFictionGame.swift  # True/false AI claims
│   │   ├── WhoMadeItGame.swift      # Match AI tools to companies
│   │   ├── WordScrambleGame.swift   # Unscramble AI terms by tapping letters
│   │   ├── FallingWordsGame.swift   # Tap falling words matching a category
│   │   ├── MemoryGridGame.swift     # Pure 4x4 card flip matching (no questions)
│   │   ├── WordSearchGame.swift     # Find AI terms in 10x10 letter grid
│   │   ├── HeartEarnGameView.swift  # Quick 5-round game to earn hearts
│   │   └── GameTutorialView.swift   # Reusable "How to Play" screen
│   ├── Progress/
│   │   └── ProgressDashboardView.swift # Stats, achievements, heatmap + gear icon → SettingsSheet
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # 7-page assessment: name, experience, role, occupation, goal, ready
│   └── Shared/
│       ├── SharedComponents.swift   # XPProgressBar, HeartsDisplay, CategoryCard, MasteryTier, etc.
│       ├── ConfettiView.swift       # Confetti particles + level-up banner
│       └── LaunchScreenView.swift   # Animated launch screen
├── Services/
│   ├── HapticService.swift     # Haptic patterns (lightTap, comboPulse, levelUp, perfectScore, cardFlip)
│   ├── SoundService.swift      # System sounds (correct, wrong, combo, select, fanfare, levelUp)
│   ├── XPService.swift         # XP calculations and level-up detection
│   ├── StreakService.swift     # Daily streak tracking
│   └── NotificationService.swift # Local push notifications
├── Extensions/
│   ├── Color+Theme.swift       # App color palette
│   ├── Font+Theme.swift        # App typography
│   ├── View+Modifiers.swift    # Shake, glow, pulse, slideIn, bounceIn modifiers
│   └── Date+Helpers.swift      # Date utilities
└── Assets.xcassets/            # App icons and colors only (no mascot assets currently)
```

### Navigation Flow
```
VizanciaApp → RootView
├── LaunchScreen (2s fade)
├── OnboardingView (if !onboardingCompleted)
│   └── 7 pages: welcome, name, experience, role, occupation, goal, ready
└── ContentView (TabView)
    ├── Home (dashboard) → LessonView → LessonCompleteView
    ├── Learn (browser) → CategoryDetailView → LessonView
    ├── Games → [11 game views]
    └── Progress (stats + gear icon → SettingsSheet)
```

### Data Model (UserProfile)
SwiftData @Model with these key properties:
- **Identity**: name, userName, experienceLevelRaw, userRoleRaw
- **Progress**: totalXP, currentLevel, totalLessonsCompleted, categoryProgressList
- **Engagement**: currentStreak, hearts, todayXP, dailyXPGoal
- **Tracking**: missedQuestionIds, categoryCorrectCounts, categoryQuestionCounts
- **Daily**: lastDailyChallengeDate, dailyChallengeStreak
- **Mid-lesson**: inProgressLessonId, inProgressQuestionIndex, inProgressCorrectCount, inProgressXPEarned
- **Settings**: soundEnabled, hapticsEnabled, notificationsEnabled

**CRITICAL**: When adding new properties to UserProfile, ALWAYS add inline default values (e.g., `var newProp: String = ""`) or SwiftData migration will fail silently → blank screen on existing users.

### Content Structure
- 16 categories, 6 lessons each, 6 questions per lesson = ~576 questions
- Learn page shows all categories as full-width cards with filter chips (All/Started/New/Complete)
- 6 question types: multipleChoice, trueFalse, fillInBlank, matchPairs, sortOrder, scenarioJudgment
- Questions reference diverse AI models (Claude, GPT, Gemini, Llama, Mistral) and companies
- Kid-friendly category names and curiosity-driven descriptions

### Categories
1. What Is AI? (ai_basics) — unlocked
2. How AI Learns (how_ai_learns) — unlocked
3. AI That Creates (generative_ai) — requires ai_basics
4. Talking to AI (prompt_engineering) — requires ai_basics
5. AI Right & Wrong (ai_ethics) — requires ai_basics
6. AI in Your Life (ai_at_work) — requires how_ai_learns minimum
7. AI Helping People (ai_healthcare) — requires how_ai_learns minimum
8. AI Art & Music (ai_creative_arts) — requires how_ai_learns minimum
9. The Story of AI (ai_history) — unlocked
10. AI Tomorrow (future_of_ai) — requires generative_ai
11. AI Words to Know (ai_vocabulary) — unlocked
12. How AI Thinks (ai_under_hood) — requires ai_basics minimum
13. Cool AI Tools (ai_tools) — requires ai_basics minimum
14. AI in Practice (ai_practice) — requires ai_basics minimum
15. AI Safety & You (ai_safety_you) — unlocked
16. Build with AI (build_with_ai) — requires ai_tools minimum

### Key Features
- **Spaced repetition**: Up to 2 missed questions injected into future lessons
- **Difficulty adaptation**: Per-category accuracy tracking, harder questions surfaced when accuracy > 85%
- **Combo streaks**: 3+ correct in a row triggers combo banner + comboPulse haptic
- **Fun facts**: One per lesson, inline in result card on first correct answer, disappears on Continue
- **Daily challenge**: One deterministic question per day with its own streak
- **Category mastery tiers**: Bronze/Silver/Gold based on accuracy + stars
- **Hearts system**: 5 hearts, lose on wrong answer, earn back via HeartEarnGameView mini-game
- **Mid-lesson save**: Progress saved on exit, resumed on re-entry
- **Lesson intro**: Shows title, description, question count, time estimate before starting
- **Answer animations**: Selected scales up, correct pulses green, wrong shakes
- **XP counting**: Slot-machine animation on lesson complete
- **Tap to continue**: Tap anywhere on result screen to advance

### Games (11 total)
| Game | Type | Mechanic |
|------|------|----------|
| Speed Round | Quiz | 60-second rapid-fire questions |
| AI Pairs | Quiz + Memory | Answer questions to flip cards, match pairs |
| Buzzword Buster | Quiz | Real vs fake AI terms |
| Jargon Match | Vocabulary | 30-second term-to-definition speed matching |
| AI Timeline | Sorting | Reorder 5 AI milestones chronologically |
| Fact or Fiction | Quiz | True/false on AI claims |
| Who Made It? | Matching | Match AI tools to companies |
| Word Scramble | Puzzle | Unscramble AI terms by tapping letters |
| Falling Words | Reflex | Tap falling words matching a category |
| Memory Grid | Memory | Pure 4x4 card flip matching, no questions |
| Word Search | Puzzle | Find AI terms in a 10x10 letter grid |

## Conventions

### Adding New Categories
1. Create `CategoryContentN.swift` in Data/
2. Follow exact pattern from CategoryContent1.swift
3. Add to `LessonContentProvider.allCategories`
4. Add to appropriate track in `LearnView` (or create new track)
5. Register in pbxproj (PBXBuildFile, PBXFileReference, PBXGroup, PBXSourcesBuildPhase)

### Adding New Games
1. Create game view in Views/Games/
2. Add case to `GameType` enum (all 5 switch properties: displayName, icon, description, color, xpReward)
3. Add to `GamesHubView.games` array and `gameView(for:)` switch
4. Register in pbxproj
5. Follow patterns from SpeedRoundGame.swift: @Bindable user, @Environment dismiss, showTutorial + GameTutorialView, gameOverView with Play Again + Done, endGame() with user.addXP/todayXP/gamesPlayed/gameHighScores

### Question ID Convention
- Category prefix + lesson number + question number
- Example: `ab1_q3` = AI Basics, Lesson 1, Question 3
- Prefixes: ab, hal, ga, pe, ae, aaw, ah, aca, aih, fa, av, auh, at, aip, asy, bwa

### Design System
- Colors: aiPrimary (#6C5CE7), aiSecondary (#00CEC9), aiOrange, aiSuccess, aiError, aiWarning
- Fonts: All use .rounded design, via Font+Theme.swift helpers
- Cards: 16pt corner radius, aiCard background, subtle shadow
- Haptics: lightTap (select), success (correct), error (wrong), comboPulse (streak), levelUp (milestone), perfectScore (celebration)
- Sounds: select (tap option), correct, wrong, comboTick, lessonComplete, perfectFanfare, levelUp — NO whoosh sounds

## UX Principles
- **Never add extra taps** between the user and their goal — every screen should have a clear single action
- **Sounds should be subtle and infrequent** — no whooshes on navigation, only earned moments (correct, combo, level-up)
- **Tips/fun facts must be inline** — never blocking overlays or popups that require extra taps to dismiss
- **Fun facts show once per lesson max** — triggered on first correct answer, disappears on Continue
- **Progress must always be saved** when user exits mid-lesson — resume from where they left off
- **Every action card must launch correctly** — use a combined struct (LessonLaunch) for lesson + category, never separate state variables that can race
- **No floating/blocking UI** that pauses the user — if info is supplementary, show it inline
- **Animations should be subtle** — spring effects on interactions, no constant bobbing or movement
- **When adding new UserProfile properties**, ALWAYS add inline default values or SwiftData migration fails silently → blank screen
- **Haptics: lightTap for selections, success/error for answers** — comboPulse and perfectScore for milestones only
- **Test every navigation path** after changes — especially fullScreenCover and sheet presentations
- **Games should have real mechanics** — not just "pick an answer" wrappers. Memory, reflexes, puzzles, sorting.
- **Keep the app kid-friendly** — simple language, curiosity-driven descriptions, no jargon in UI

## Testing Checklist
- [ ] Delete app from simulator before testing (SwiftData schema changes)
- [ ] Complete onboarding flow (all 7 pages)
- [ ] Play at least 1 lesson — verify fun fact shows once, inline
- [ ] Exit mid-lesson and re-enter — verify resume from saved position
- [ ] Trigger combo streak (3+ correct)
- [ ] Complete a lesson perfectly (verify confetti + XP counting animation)
- [ ] Level up (verify banner + sound)
- [ ] Run out of hearts (verify "Play for Hearts" flow)
- [ ] Play each mini-game (11 games)
- [ ] Check daily challenge
- [ ] Tap "Continue Learning" on home — verify no white screen
- [ ] Tap "Quick Play" — verify lesson launches correctly
- [ ] Check all 16 categories load on Learn page
- [ ] Check filter chips (All/Started/New/Complete)
- [ ] Check Progress tab — stats, achievements, activity heatmap
- [ ] Check Settings (gear icon) — all toggles, name, daily goal, links
- [ ] Verify contact support email (mailto:info@vizancia.ca)

## App Store
- **Bundle ID**: ca.vizancia.app
- **Version**: 2.0.0
- **Contact**: info@vizancia.ca
- **Privacy**: https://odin686.github.io/Vizancia/privacy-policy.html
- **Terms**: https://odin686.github.io/Vizancia/terms-of-service.html
