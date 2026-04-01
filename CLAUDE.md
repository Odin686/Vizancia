# Vizancia - AI Learning App

## Overview
Vizancia is an iOS app that teaches AI literacy through gamified lessons, quizzes, and mini-games. Positioned as "the Duolingo of AI." Built with SwiftUI + SwiftData, no backend dependencies.

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
│   └── ContentView.swift       # TabView (Learn, Games, Progress, Profile)
├── Models/
│   ├── User.swift              # UserProfile @Model (SwiftData)
│   ├── Question.swift          # Question, LessonData, CategoryData, GameType, etc.
│   └── Achievement.swift       # AchievementData with conditions
├── Data/
│   ├── LessonContentProvider.swift  # Central content registry
│   ├── CategoryContent1-13.swift    # 13 categories, ~468 questions
│   └── FunFacts.swift               # 30 AI fun facts for between-question display
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift           # Main screen: Viz mascot, stats, horizontal carousels
│   │   └── CategoryDetailView.swift # Lesson list within a category
│   ├── Lesson/
│   │   ├── LessonView.swift         # Quiz engine: questions, combos, spaced repetition
│   │   ├── LessonCompleteView.swift # Results: stars, XP counting, confetti, level-up
│   │   ├── QuestionViews.swift      # All 6 question type views + OptionButton
│   │   ├── PracticeMistakesView.swift # Review missed questions
│   │   └── DailyChallengeView.swift  # Daily question for bonus XP
│   ├── Games/
│   │   ├── GamesHubView.swift       # Game list
│   │   ├── SpeedRoundGame.swift     # 60-second rapid-fire quiz
│   │   ├── AIOrNotGame.swift        # AI vs human quote identification
│   │   ├── AIPairsGame.swift        # Memory card matching + quiz hybrid
│   │   ├── PromptCraftGame.swift    # Pick the best prompt
│   │   ├── BuzzwordBusterGame.swift # Real vs fake AI terms
│   │   ├── JargonMatchGame.swift    # 30-second term-to-definition speed game
│   │   ├── HeartEarnGameView.swift  # Quick 5-round game to earn hearts
│   │   └── GameTutorialView.swift   # Reusable "How to Play" screen
│   ├── Progress/
│   │   └── ProgressDashboardView.swift # Stats, achievements with progress bars, heatmap
│   ├── Profile/
│   │   └── ProfileView.swift        # Settings, name, daily goal, reset
│   ├── Onboarding/
│   │   └── OnboardingView.swift     # 7-page assessment: name, experience, role, goal
│   └── Shared/
│       ├── SharedComponents.swift   # XPProgressBar, HeartsDisplay, CategoryCard, etc.
│       ├── VizMascotView.swift      # Viz robot with eye-pop animation
│       ├── ConfettiView.swift       # Confetti particles + level-up banner
│       └── LaunchScreenView.swift   # Animated launch screen
├── Services/
│   ├── HapticService.swift     # Haptic patterns (combo, levelUp, perfectScore, etc.)
│   ├── SoundService.swift      # System sounds (correct, wrong, combo, whoosh, fanfare)
│   ├── XPService.swift         # XP calculations and level-up detection
│   ├── StreakService.swift     # Daily streak tracking
│   └── NotificationService.swift # Local push notifications
├── Extensions/
│   ├── Color+Theme.swift       # App color palette
│   ├── Font+Theme.swift        # App typography
│   ├── View+Modifiers.swift    # Shake, glow, pulse, slideIn modifiers
│   └── Date+Helpers.swift      # Date utilities
└── Assets.xcassets/
    ├── viz_happy.imageset/     # Viz mascot body
    └── viz_eye.imageset/       # Viz eye for animation
```

### Navigation Flow
```
VizanciaApp → RootView
├── LaunchScreen (2s fade)
├── OnboardingView (if !onboardingCompleted)
│   └── 7 pages: welcome, name, experience, role, occupation, goal, ready
└── ContentView (TabView)
    ├── HomeView (dashboard) → LessonView → LessonCompleteView
    ├── LearnView (category browser) → CategoryDetailView → LessonView
    ├── GamesHubView → [10 game views]
    └── ProgressDashboardView (stats + gear icon → SettingsSheet)
```

### Data Model (UserProfile)
SwiftData @Model with these key properties:
- **Identity**: name, userName, experienceLevelRaw, userRoleRaw
- **Progress**: totalXP, currentLevel, totalLessonsCompleted, categoryProgressList
- **Engagement**: currentStreak, hearts, todayXP, dailyXPGoal
- **Tracking**: missedQuestionIds, categoryCorrectCounts, categoryQuestionCounts
- **Daily**: lastDailyChallengeDate, dailyChallengeStreak
- **Settings**: soundEnabled, hapticsEnabled, notificationsEnabled

**Important**: When adding new properties to UserProfile, ALWAYS add inline default values (e.g., `var newProp: String = ""`) or SwiftData migration will fail silently → blank screen.

### Content Structure
- 16 categories, 6 lessons each, 6 questions per lesson = ~576 questions
- 5 tracks: Start Here, Level Up, Go Deeper, Real World, Explore
- 6 question types: multipleChoice, trueFalse, fillInBlank, matchPairs, sortOrder, scenarioJudgment
- Questions reference diverse AI models (Claude, GPT, Gemini, Llama, Mistral) and companies

### Key Features
- **Spaced repetition**: Missed questions injected into future lessons
- **Difficulty adaptation**: Per-category accuracy tracking, harder questions surfaced when accuracy > 85%
- **Combo streaks**: 3+ correct in a row triggers celebration
- **Fun facts**: Shown between questions 2→3 and 4→5
- **Daily challenge**: One question per day with its own streak
- **Category mastery tiers**: Bronze/Silver/Gold based on accuracy + stars
- **Hearts system**: 5 hearts, lose on wrong answer, earn back via mini-game
- **Viz mascot**: Robot character with random eye-pop animation every 30-90s

## Conventions

### Adding New Categories
1. Create `CategoryContentN.swift` in Data/
2. Follow exact pattern from CategoryContent1.swift
3. Add to `LessonContentProvider.allCategories`
4. Add to appropriate track in `HomeView.tracks`
5. Register in pbxproj (PBXBuildFile, PBXFileReference, PBXGroup, PBXSourcesBuildPhase)

### Adding New Games
1. Create game view in Views/Games/
2. Add case to `GameType` enum (all 6 switch properties)
3. Add to `GamesHubView.games` array and `gameView(for:)` switch
4. Register in pbxproj

### Question ID Convention
- Category prefix + lesson number + question number
- Example: `ab1_q3` = AI Basics, Lesson 1, Question 3
- Prefixes: ab, hal, ga, pe, ae, aaw, ah, aca, aih, fa, av, auh, at

### Design System
- Colors: aiPrimary (#6C5CE7), aiSecondary (#00CEC9), aiOrange, aiSuccess, aiError, aiWarning
- Fonts: All use .rounded design, via Font+Theme.swift helpers
- Cards: 16pt corner radius, aiCard background, subtle shadow
- Haptics: lightTap (select), success (correct), error (wrong), comboPulse, levelUp, perfectScore

## UX Principles
- **Never add extra taps** between the user and their goal — every screen should have a clear single action
- **Sounds should be subtle and infrequent** — no whooshes on navigation, only earned moments (correct, combo, level-up)
- **Tips/fun facts must be inline** — never blocking overlays or popups that require extra taps to dismiss
- **Fun facts show once per lesson max** — triggered on first correct answer, disappears on Continue
- **Progress must always be saved** when user exits mid-lesson — resume from where they left off
- **Every action card must launch correctly** — never use separate state variables for lesson + category; use a combined struct to avoid nil race conditions
- **No floating/blocking UI** that pauses the user — if info is supplementary, show it inline
- **Animations should be subtle** — spring effects on interactions, no constant bobbing or movement
- **When adding new UserProfile properties**, ALWAYS add inline default values or SwiftData migration fails silently → blank screen
- **Haptics: lightTap for selections, success/error for answers** — comboPulse and perfectScore for milestones only
- **Test every navigation path** after changes — especially fullScreenCover and sheet presentations

## Testing Checklist
- [ ] Delete app from simulator before testing (SwiftData schema changes)
- [ ] Complete onboarding flow (all 7 pages)
- [ ] Play at least 1 lesson — verify fun fact shows once, inline
- [ ] Exit mid-lesson and re-enter — verify resume from saved position
- [ ] Trigger combo streak (3+ correct)
- [ ] Complete a lesson perfectly (verify confetti + XP counting animation)
- [ ] Level up (verify banner + sound)
- [ ] Run out of hearts (verify "Play for Hearts" flow)
- [ ] Play each mini-game (10 games)
- [ ] Check daily challenge
- [ ] Tap "Continue Learning" on home — verify no white screen
- [ ] Tap "Quick Play" — verify lesson launches correctly
- [ ] Check all 16 categories load on Learn page
- [ ] Check filter chips (All/Started/New/Complete)
- [ ] Check Progress tab — stats, achievements, activity heatmap
- [ ] Check Settings (gear icon) — all toggles, name, daily goal, links

## App Store
- **Bundle ID**: ca.vizancia.app
- **Version**: 2.0.0
- **Contact**: info@vizancia.ca
- **Privacy**: https://odin686.github.io/Vizancia/privacy-policy.html
- **Terms**: https://odin686.github.io/Vizancia/terms-of-service.html
