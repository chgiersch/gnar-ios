# GNAR – iOS App (Work in Progress)

**DISCLAIMER**  
This app is a **personal, non-commercial project** inspired by the original GNAR game, created by Shane McConkey and popularized by Unofficial Networks and the film *GNAR: The Movie*.  
I do **not claim ownership** over the GNAR game concept or any original material associated with it. This is built **for educational purposes only** — to explore app development patterns, SwiftUI architecture, and playful design.

If you're affiliated with the original creators and have concerns, feel free to contact me. I'll respectfully respond and take appropriate action. In fact, I've already been in touch multiple times and look forward to connecting more! 

---

## 🎿 What is GNAR?

GNAR stands for **Gaffney's Numerical Assessment of Radness** — a game where you earn points for skiing hard, doing ridiculous things (like farting in the tram), and not taking yourself too seriously.  
This app is a digital homage to that spirit: **a silly, honor-based, ego-busting ski game**, rebuilt in SwiftUI.

---

## 🚧 Project Status

This is an **in-progress SwiftUI app**, being built from the ground up with modern architecture.  
I'm using it to:
- Practice MVVM with real-world complexity
- Integrate Core Data + CloudKit syncing
- Experiment with MultipeerConnectivity
- Have fun and make people laugh

---

## 🧱 Architecture & Tech Stack

### 🔧 Core Patterns
- **MVVM (Model-View-ViewModel)** – for scalable state management
- **Repository Pattern** – for Core Data encapsulation and testability
- **Domain-driven Models** – for decoupling game logic from UI

### 🧰 Frameworks & Features
- **SwiftUI** – all UI written with modern declarative components
- **Core Data + CloudKit** – local/offline-first with iCloud syncing (iOS-only)
- **MultipeerConnectivity** – for peer-to-peer GNAR sessions without internet (WIP)
- **Voice Input (Planned)** – log scores via spoken phrases using Speech Recognition
- **Score system** – supports multiple categories:
  - `LineWorths`, `TrickBonuses`, `ECPs` (Extra Credit Points), and `Penalties`
- **Leaderboard** – toggle between GNAR and Pro scoring logic
- **Offline Mode** – log everything without cell service and sync later
- **Theming** – support for Light/Dark mode and system tinting via Asset Catalog
- **Testing** – test targets for UI and model-level coverage (early stage)

---

## 📦 Features Implemented So Far

- [x] Tab-based navigation: Home, Games, Profile
- [x] Pinned headers in scrollable views
- [x] ScrollView with safe area handling and tab bar protection
- [x] GNAR directions + gameplay rules (for onboarding)
- [x] Create game sessions and manually log scores
- [x] LineWorths with dynamic tiered points (by snow level)
- [x] Trick bonuses, ECPs, and Penalties with category support
- [x] Real-time score preview with pill-style breakdown
- [x] Editable score history
- [x] Custom tab bar appearance
- [x] Core Data stack with view + background contexts
- [x] Lazy loading of games with "Load More" batching
- [x] Profile setup screen (WIP)
- [x] Multipeer player syncing architecture (in progress)

---

## 🛠 In Progress / Planned

- [ ] MultipeerConnectivity syncing (offline peer games)
- [ ] Game sharing/invites
- [ ] Player color + emoji customization
- [ ] Mountain-specific ECPs and LineWorths
- [ ] iCloud syncing via CloudKit
- [ ] Game recap & end-of-day celebration

---

## 🎮 Game Rules

1. **Self-deprecation is power**: Earn respect by embarrassing yourself in public with confidence
2. **Call your line**: Announce your intended line before dropping in
3. **Style over everything**: It's not just what you do, it's how you do it
4. **Honor system**: Be real, be ridiculous, be GNAR
5. **No faking**: Authentic points only, that's the GNAR way

---

## 💼 About Me

I'm [Chris Giersch](https://github.com/chrisgiersch), a former iOS engineer turned product owner and designer, now returning to hands-on engineering with a passion for beautiful UI, offline-first mobile apps, and silly ideas that bring people together.

- ⛷️ Background in iOS, UX and design, GIS, and regenerative land projects
- 🧠 Love building joyful, clean software with modern best practices
- 🤝 Open to freelance, contracting, or full-time opportunities

---

## 📬 Contact

If you're a dev, designer, skier, or employer — I'd love to hear from you:

- Email: chgiersch@gmail.com
- GitHub: [@chrisgiersch](https://github.com/chrisgiersch)  

---

## 🧾 License

This project is for educational purposes only. No rights are granted for use, 
modification, or distribution. The GNAR game concept and related materials 
remain the property of their respective owners.