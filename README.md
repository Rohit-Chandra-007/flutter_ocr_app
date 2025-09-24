# Smart OCR Scanner

A Flutter app for extracting text from PDFs and images using Google ML Kit OCR.

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── app/                         # App-level configuration
│   ├── app.dart                # Main app widget
│   └── theme/                  # Theme configuration
│       └── app_theme.dart      # Light/dark themes
├── features/                   # Feature-based modules
│   └── ocr/                   # OCR functionality
│       ├── screens/           # Screen widgets
│       │   └── ocr_screen.dart
│       ├── widgets/           # Feature-specific widgets
│       │   ├── file_picker_menu.dart
│       │   ├── progress_overlay.dart
│       │   ├── result_view.dart
│       │   └── empty_state.dart
│       └── services/          # Business logic
│           ├── ocr_service.dart
│           └── pdf_service.dart
├── core/                      # Core utilities
│   ├── constants/            # App constants
│   │   └── app_constants.dart
│   └── utils/               # Utility functions
│       └── file_utils.dart
└── shared/                   # Shared components
    └── widgets/             # Reusable widgets
        └── custom_button.dart
```

## 🏗️ Architecture Benefits

- **Feature-based organization**: Each feature is self-contained
- **Separation of concerns**: UI, business logic, and utilities are separated
- **Reusability**: Shared components can be used across features
- **Maintainability**: Easy to locate and modify specific functionality
- **Scalability**: Easy to add new features without cluttering

## 🚀 Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## 📱 Features

- Extract text from images using camera or gallery
- Extract text from PDF documents
- Edit extracted text
- Copy text to clipboard
- Share extracted text
- Progress tracking for PDF processing
- Beautiful animations and UI
