# Gemini Project Context: ScanFlow OCR App

This document provides a comprehensive overview of the ScanFlow project, a Flutter-based OCR mobile application. It is intended to be used as a contextual guide for AI-assisted development.

## 1. Project Overview

ScanFlow is a modern, intuitive OCR (Optical Character Recognition) mobile application built with Flutter. It transforms a mobile device into a powerful document scanner with text recognition capabilities.

**Core Features:**

*   **Live Camera Scanning:** Instant text recognition directly from the camera feed.
*   **Image & PDF Import:** Process images from the gallery or import existing PDFs.
*   **Smart Text Recognition:** Powered by Google ML Kit for accurate OCR.
*   **Document History:** Organized storage of all scanned documents in a local database.
*   **Modern UI:** A clean, minimalist design with light and dark themes, smooth animations, and a consistent design system.

## 2. Architecture

The project follows a feature-based architecture, promoting a clean separation of concerns and scalability.

```
lib/
├── main.dart             # App entry point with Riverpod
├── app/                  # App-level configuration (main widget, theme)
├── core/                 # Shared utilities (models, services, constants)
├── features/             # Feature modules (camera, ocr, scan_history)
└── shared/               # Reusable widgets
```

## 3. Key Technologies

*   **Framework:** [Flutter](https://flutter.dev/) (version >=3.0.0)
*   **Language:** [Dart](https://dart.dev/)
*   **State Management:** [Riverpod](https://riverpod.dev/)
*   **OCR Engine:** [Google ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition)
*   **Database:** [Isar](https://isar.dev/) (a high-performance NoSQL database for Flutter)
*   **UI & Animations:**
    *   [Material 3](https://m3.material.io/)
    *   [Google Fonts (Inter)](https://fonts.google.com/specimen/Inter)
    *   [Flutter Animate](https://pub.dev/packages/flutter_animate)
*   **Linting:** [flutter_lints](https://pub.dev/packages/flutter_lints)

## 4. Building and Running

### Prerequisites

*   Flutter SDK (>=3.0.0)
*   Dart SDK
*   Android Studio / VS Code
*   A physical device or emulator

### Commands

*   **Install dependencies:**
    ```bash
    flutter pub get
    ```

*   **Run the app (debug mode):**
    ```bash
    flutter run
    ```

*   **Run tests:**
    ```bash
    flutter test
    ```

*   **Build for release (Android):**
    ```bash
    # APK
    flutter build apk --release

    # App Bundle
    flutter build appbundle --release
    ```

*   **Build for release (iOS):**
    ```bash
    flutter build ios --release
    ```

## 5. Development Conventions

*   **Coding Style:** The project follows the standard Dart and Flutter conventions enforced by the `flutter_lints` package.
*   **State Management:** State is managed using Riverpod. Providers are used to separate business logic from the UI.
*   **Immutability:** Following Riverpod's principles, the app likely favors immutable data structures.
*   **Asynchronous Operations:** Asynchronous operations (like camera access, file I/O, and OCR) are handled using `Future`s and `async/await`.

## 6. Core Components

*   **`lib/main.dart`:** The entry point of the application. It initializes the Flutter app and sets up the `ProviderScope` for Riverpod.
*   **`lib/app/app.dart`:** Contains the main `ScanFlowApp` widget, which is a `MaterialApp` that defines the app's title, themes, and initial route.
*   **`lib/app/theme/app_theme.dart`:** Defines the application's design system, including color palettes, typography (using the Inter font), spacing, and theme data for both light and dark modes.
*   **`lib/core/models/scan_document.dart`:** The core data model for a scanned document. It's an Isar collection with fields for title, extracted text, image paths, and timestamps.
*   **`lib/features/camera/screens/camera_screen.dart`:** A key feature screen that handles camera initialization, permission requests, photo capture, and the OCR processing workflow. It uses the `camera` plugin for camera access and the `google_mlkit_text_recognition` plugin (via `OCRService`) to process the captured image.
*   **`lib/features/scan_history/screens/scan_history_screen.dart`:** This screen is responsible for displaying the list of previously scanned documents from the Isar database.
