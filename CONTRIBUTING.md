# Contributing to GNAR

Hi there! 👋 Thanks for checking out GNAR. While this is currently a personal project, I'm open to ideas, feedback, and pull requests.

## 🙌 How to Contribute

1. Fork this repo
2. Create a new branch (`feature/your-feature-name`)
3. Make your changes
4. Run SwiftLint (`swiftlint`)
5. Submit a pull request

### 🧪 Tips

- Follow MVVM best practices
- Use descriptive commit messages
- Comment tricky logic
- Stick to the style defined by `.swiftlint.yml`

## 🏗 Project Structure

```
GNAR/
├── Views/                  # SwiftUI views
│   ├── Root Views/         # Main navigation and tab views
│   └── GameDashboard Views/# Game session related views
├── View Models/            # View models following MVVM
├── Models/                 # Core Data models and business logic
├── Services/              # Network, persistence, and other services
└── Resources/             # Assets, localization, etc.
```

## 📝 Code Style

- Use SwiftLint for consistent style
- Follow Apple's Swift API Design Guidelines
- Keep functions small and focused
- Use meaningful variable and function names
- Document public interfaces

## 🧪 Testing

- Write unit tests for business logic
- Include UI tests for critical flows
- Test edge cases and error conditions
- Document test coverage

## 🔄 Git Workflow

1. Create feature branches from `dev`
2. Keep commits focused and atomic
3. Write clear commit messages
4. Rebase before submitting PRs
5. Squash commits when appropriate

## 🚀 Getting Started

1. Clone the repository
2. Open `GNAR.xcodeproj`
3. Install dependencies (if any)
4. Build and run the project
5. Check out the `dev` branch for latest changes

## 🤝 Pull Request Process

1. Update the README.md with details of changes
2. Update the CHANGELOG.md
3. Ensure all tests pass
4. Get a code review from at least one person
5. Merge only after approval

## 📬 Questions?

If you're unsure where to start, check out the open issues or DM me on GitHub!

— Chris 