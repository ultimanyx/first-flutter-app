# My Notes (`notes_app`)

A clean, lightweight Android notes application built with **Flutter** and **Dart** using Material 3 and local persistent storage.

## Features

- **Create & Edit Notes:** Full-screen distraction-free editor for writing titles and multi-line note bodies.
- **Local Persistence:** Automatically saves and loads notes on the device using `shared_preferences` with JSON serialization—no internet connection required.
- **Safe Deletion:** Includes a confirmation dialog before permanently removing a note.
- **Material 3 UI:** Clean card-based list view with automatic text truncation and custom launcher icon support.

## Tech Stack

- **Framework:** Flutter (Material 3)
- **Language:** Dart (`^3.13.7`)
- **Packages:**
  - `shared_preferences` (`^2.5.6`) — local key-value storage
  - `flutter_launcher_icons` (`^0.14.4`) — adaptive app icon generation

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured
- Android SDK / connected Android device with USB debugging enabled

### Run Locally

1. Clone the repository:
   ```bash
   git clone [https://github.com/ultimanyx/first-flutter-app.git](https://github.com/ultimanyx/first-flutter-app.git)
   cd first-flutter-app
   ```
