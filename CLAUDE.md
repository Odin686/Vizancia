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
    ├── HomeView → CategoryDetailView → LessonView → LessonCompleteView
    ├── GamesHubView → [7 game views]
    ├── ProgressDashboardView
    └── ProfileView
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
- 13 categories, 6 lessons each, 6 questions per lesson = ~468 questions
- 4 tracks: Foundations, Skills, Deep Dive, Big Picture
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

## Testing Checklist
- [ ] Delete app from simulator before testing (SwiftData schema changes)
- [ ] Complete onboarding flow (all 7 pages)
- [ ] Play at least 1 lesson per track
- [ ] Trigger combo streak (3+ correct)
- [ ] Complete a lesson perfectly (verify confetti + XP counting)
- [ ] Level up (verify banner + sound)
- [ ] Run out of hearts (verify "Play for Hearts" flow)
- [ ] Play each mini-game
- [ ] Check daily challenge
- [ ] Verify all 13 categories load in horizontal carousels

## App Store
- **Bundle ID**: ca.vizancia.app
- **Version**: 2.0.0 (pending)
- **Contact**: info@vizancia.com
- **Privacy**: https://odin686.github.io/Vizancia/privacy-policy.html
- **Terms**: https://odin686.github.io/Vizancia/terms-of-service.html
