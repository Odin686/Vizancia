# 🧠 AI Academy

**Learn AI the fun way** — A gamified iOS app that teaches Artificial Intelligence concepts to everyday people through interactive lessons, quizzes, and mini-games.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-purple)
![SwiftData](https://img.shields.io/badge/SwiftData-✓-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## ✨ Features

### 📚 10 Learning Paths (60 Lessons, 360 Questions)
| # | Category | Topics |
|---|----------|--------|
| 1 | **AI Basics** | What is AI, Machine Learning, Neural Networks |
| 2 | **How AI Learns** | Supervised, Unsupervised, Reinforcement Learning |
| 3 | **Generative AI** | LLMs, Transformers, Hallucinations |
| 4 | **Prompt Engineering** | Techniques, System Prompts, Best Practices |
| 5 | **AI Ethics & Safety** | Bias, Deepfakes, Privacy, Regulation |
| 6 | **AI at Work** | Automation, Hiring, Productivity Tools |
| 7 | **AI in Healthcare** | Medical Imaging, Drug Discovery, Diagnostics |
| 8 | **AI in Creative Arts** | Visual Art, Music, Writing, Copyright |
| 9 | **AI History & Pioneers** | Turing, AI Winters, Deep Learning Revolution |
| 10 | **Future of AI** | AGI, Existential Risk, Governance |

### 🎮 6 Interactive Question Types
- Multiple Choice
- True / False
- Fill in the Blank
- Scenario Judgment
- Match Pairs
- Sort Order

### 🕹️ 5 Mini-Games
| Game | Description |
|------|-------------|
| ⚡ **Speed Round** | Answer as many questions as you can in 60 seconds |
| 🤖 **AI or Not?** | Guess if a statement was made by AI or a human |
| ⚖️ **Ethics Court** | Judge real-world AI ethical dilemmas |
| ✍️ **Prompt Craft** | Pick the best prompt for each scenario |
| 🔤 **Buzzword Buster** | Identify real vs fake AI terminology |

### 🏆 Gamification System
- **12 Levels** — AI Curious → Singularity Scholar
- **XP Rewards** — Earn XP for correct answers, lesson completion, and perfect scores
- **Daily Streaks** — Build a learning habit with streak tracking
- **Hearts System** — 5 hearts per day, daily refill
- **20+ Achievements** — Unlock milestones as you learn
- **Daily Goals** — 4 tiers (Casual, Regular, Serious, Intense)
- **Star Ratings** — Earn up to 3 stars per lesson

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Language** | Swift 5.9+ |
| **UI Framework** | SwiftUI |
| **Persistence** | SwiftData |
| **Target** | iOS 17.0+ |
| **Architecture** | MVVM |
| **Backend** | None — fully offline |

---

## 📁 Project Structure

```
AIAcademy/
├── App/              # Entry point + Tab navigation
├── Models/           # SwiftData models (User, Question, Achievement)
├── Data/             # 10 category content files (360 questions)
├── Services/         # XP, Streak, Haptic, Sound, Notification
├── Extensions/       # Color, Font, Date, View theming
└── Views/
    ├── Home/         # Category grid + detail screen
    ├── Lesson/       # Lesson engine + 6 question type views
    ├── Games/        # 5 mini-games
    ├── Progress/     # Dashboard with stats + achievements
    ├── Profile/      # Settings + daily goal picker
    ├── Onboarding/   # 5-screen intro flow
    └── Shared/       # Reusable UI components
```

---

## 🚀 Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/Odin686/Allyai.git
   cd Allyai
   ```

2. **Open in Xcode**
   ```bash
   open AIAcademy.xcodeproj
   ```

3. **Build & Run**
   - Select an iOS 17+ simulator
   - Press `Cmd + R`

---

## 📸 App Flow

```
Onboarding → Home (Learning Paths Grid)
                ├── Category Detail → Lesson → Completion Screen
                ├── Mini-Games Hub → 5 Games
                ├── Progress Dashboard (Stats, Achievements, Activity)
                └── Profile (Settings, Goals, Hearts)
```

---

## 📄 License

This project is licensed under the MIT License.

---

Made with 💜 and a lot of AI knowledge
