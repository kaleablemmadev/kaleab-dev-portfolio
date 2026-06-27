# Misol Calendar 📅

A high-performance, aesthetically pleasing Flutter calendar application featuring glassmorphism UI, smooth transitions, and a robust navigation architecture.

## 🚀 Recent Navigation Audit & Fixes

The application has undergone a complete navigation overhaul to ensure a seamless user experience and memory efficiency.

### Key Fixes:
- **Stack Management:** Replaced inconsistent `Navigator.push` calls with `pushReplacementNamed` for view-switching (Month/Week/Day) to prevent navigation stack bloat.
- **Dead Button Resolution:** All AppBar actions (Search, Notifications) now provide user feedback via SnackBars instead of remaining non-functional.
- **Context-Aware Navigation:** Implemented `onGenerateRoute` for safe argument passing between screens (Dates and Event objects).
- **Dialog & Sheet Handling:** Standardized `Navigator.pop` usage to ensure all overlays are cleared before secondary navigation occurs.
- **Back-Button Logic:** Improved leading icons to dynamically hide when a screen is the root of the view hierarchy.

## 📱 Features

- **Multi-View Calendar:** Seamlessly switch between Month, Week, and Day views.
- **Agenda View:** A clean, grouped list of all upcoming events.
- **Interactive Grid:** Tap dates to add events or view specific day details.
- **Event Management:** Full CRUD (Create, Read, Update, Delete) with Undo functionality.
- **Glassmorphism UI:** Modern frosted-glass aesthetic with dark mode support.
- **Multi-Select Mode:** Delete or manage multiple events simultaneously.

## 🛠 Tech Stack

- **Framework:** Flutter (Material 3)
- **State Management:** ChangeNotifier / ListenableBuilder
- **Storage:** Shared Preferences (Settings)
- **Icons:** Material Icons & SF Pro Display font

## 📂 Project Structure

- `lib/screens/`: Main UI screens (Home, Calendar, Agenda, etc.)
- `lib/widgets/`: Reusable UI components (Grid, Event Cards, Color Picker)
- `lib/services/`: Business logic (Event persistence, Selection logic, Settings)
- `lib/models/`: Data structures (Event model)
- `lib/ui/`: Shared UI theme components and glass effects

## 🏁 Getting Started

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
2. **Run the App:**
   ```bash
   flutter run
   ```

---
*Built with ❤️ using Flutter*
