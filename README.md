# ScanFlow - Beautiful OCR Scanner

A modern, intuitive OCR (Optical Character Recognition) mobile application built with Flutter. ScanFlow transforms your device into a powerful document scanner with beautiful UI, smooth animations, and intelligent text recognition.

## ✨ Features

### 🎯 Core Functionality
- **Live Camera Scanning**: Instant text recognition directly from camera feed
- **Multi-page Support**: Scan and combine multiple pages into single documents
- **Image & PDF Import**: Process images from gallery or import existing PDFs
- **Smart Text Recognition**: Powered by Google ML Kit for accurate OCR
- **Document History**: Organized storage of all scanned documents

### 🎨 Beautiful Design
- **Modern UI**: Clean, minimalist design with Inter font family
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Dark/Light Themes**: Automatic theme switching based on system preference
- **Intuitive Navigation**: Easy-to-use interface with clear visual hierarchy

### 📱 User Experience
- **Interactive Text Editing**: Edit extracted text directly in the app
- **Smart Search**: Find documents by title or content
- **Export Options**: Copy to clipboard, share as text, or export as PDF
- **Progress Tracking**: Visual feedback during document processing

## 🏗️ Architecture

ScanFlow follows a clean, scalable architecture with feature-based organization:

```
lib/
├── main.dart                           # App entry point with Riverpod
├── app/                               # App-level configuration
│   ├── app.dart                      # Main app widget
│   └── theme/                        # Design system
│       └── app_theme.dart           # Colors, typography, spacing
├── features/                         # Feature modules
│   ├── scan_history/                # Document history
│   │   ├── screens/                 # Home screen
│   │   ├── widgets/                 # History cards, search
│   │   └── providers/               # State management
│   ├── camera/                      # Camera scanning
│   │   └── screens/                 # Camera interface
│   └── ocr/                         # Text recognition
│       ├── services/                # OCR & PDF processing
│       └── widgets/                 # Result views
├── core/                            # Shared utilities
│   ├── models/                      # Data models
│   ├── services/                    # Database, samples
│   ├── constants/                   # App constants
│   └── utils/                       # Helper functions
└── shared/                          # Reusable components
    └── widgets/                     # Custom buttons, etc.
```

## 🎨 Design System

### Color Palette
- **Primary Blue**: `#4A90E2` - Main brand color
- **Accent Teal**: `#50E3C2` - Secondary actions
- **Accent Orange**: `#F5A623` - Highlights and CTAs

### Typography
- **Font Family**: Inter (Google Fonts)
- **Type Scale**: Consistent sizing from display to caption
- **Weight Hierarchy**: 400 (regular) to 700 (bold)

### Spacing System
- **Base Unit**: 4px increments (4, 8, 12, 16, 20, 24, 32)
- **Consistent Margins**: Applied throughout the app
- **Responsive Layout**: Adapts to different screen sizes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Physical device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/scanflow.git
   cd scanflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires macOS and Xcode)
flutter build ios --release
```

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language

### State Management
- **Riverpod**: Reactive state management
- **Provider Pattern**: Clean separation of concerns

### OCR & Camera
- **Google ML Kit**: Text recognition engine
- **Camera Plugin**: Native camera access
- **Image Picker**: Gallery integration

### Storage & Data
- **SharedPreferences**: Local data persistence
- **Path Provider**: File system access
- **UUID**: Unique document identifiers

### UI & Animations
- **Flutter Animate**: Smooth animations and transitions
- **Google Fonts**: Inter typography
- **Material 3**: Modern design components

## 📱 Screenshots

*Coming soon - Beautiful screenshots of the app in action*

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google ML Kit team for excellent OCR capabilities
- Flutter team for the amazing framework
- Inter font family by Rasmus Andersson
- All contributors and testers

---

**ScanFlow** - Transform your documents, digitize your world. 📄✨
