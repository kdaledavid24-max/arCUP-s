# ☕ arCUP's - Food & Coffee Ordering App

[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20Windows-green)](https://github.com/kdaledavid24-max/arCUP-s)
[![Build Status](https://img.shields.io/badge/Build-Release%20APK%20Ready-brightgreen)](https://github.com/kdaledavid24-max/arCUP-s/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**arCUP's** is a cross-platform mobile and web food-ordering application developed with **Flutter** and **Dart**. Designed with an intuitive cafe experience in mind, it allows customers to easily explore a diverse menu of handcrafted beverages, frappes, pasta dishes, and salads, customize their orders with flexible options, manage a live cart, track order statuses in real time, and provides administrators with a full-featured management dashboard.

---

## 📱 Download & Install on Android

The Android APK is built and ready for download:

* **Direct Release Page**: [arCUP's Releases on GitHub](https://github.com/kdaledavid24-max/arCUP-s/releases)
* **Direct APK Download**: [`app-release.apk` (v1.0.0)](https://github.com/kdaledavid24-max/arCUP-s/releases/download/v1.0.0/app-release.apk)

### Installation Guide for Android Devices:
1. Tap the direct download link above from your Android phone's web browser.
2. When the download completes, tap the download notification or locate `app-release.apk` in your **Downloads** folder.
3. If your device displays a security prompt stating that installs from your browser or file manager are blocked:
   - Tap **Settings** in the prompt.
   - Toggle **Allow from this source** (or *Install unknown apps*).
4. Return and tap **Install**.
5. Once installation finishes, tap **Open** to launch **arCUP's**!

---

## ✨ Features & Functionality

### 🛒 Customer Experience
- **Interactive Menu & Categorization**: Smooth filtering across *All Items*, *Hot Drinks*, *Frappes*, *Ice Blended*, *Pasta*, and *Fresh Salads*.
- **Product Customization**: Detailed modifier selections including cup sizes (Small, Regular, Large), sweetness levels, extra toppings, and custom notes.
- **Cart Management**: Add items, adjust quantities, calculate itemized subtotals, VAT, and discounts in real time.
- **Live Order Tracking**: Track orders from confirmation to preparation and completion with dynamic progress indicators and timestamps.
- **Image Zoom Dialog**: High-resolution image viewing dialog for menu items.

### 🛠️ Admin Management Suite
- **Product Catalog Management**: Add, edit, or remove menu items with instant preview.
- **Photo Attachments**: Upload custom food photos via system file picker or camera/gallery, with automatic compression for smooth performance and storage safety.
- **Category & Stock Controls**: Easily assign categories, set prices, and toggle in-stock availability.
- **Order Monitoring**: View live incoming orders and update order preparation states.
- **Sales Analytics & Reports**: View revenue trends, sales summaries, and top-performing items.

---

## 🏗️ Architecture & Technologies

- **Framework**: [Flutter SDK](https://flutter.dev/) (Channel stable, v3.47.6)
- **Language**: [Dart](https://dart.dev/) (v3.13.5)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `Consumer`)
- **Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences) & local storage layer
- **File & Media Handling**: [image_picker](https://pub.dev/packages/image_picker), [file_picker](https://pub.dev/packages/file_picker)
- **Design & UI**: Material 3 theming with custom warm cafe palette and fluid responsive layouts
- **Automated Testing**: Flutter Widget & Unit tests ensuring 100% test pass rate for all core logic

---

## 🚀 Local Development Setup

To run and build this application locally:

### Prerequisites
1. **Flutter SDK** (3.47.x or higher) installed and configured in your `PATH`.
2. **Dart SDK** (included with Flutter).
3. **Android Build Environment** (for building local Android APK):
   - **Java Development Kit (JDK 17)**: e.g. OpenJDK / Eclipse Temurin 17.
   - **Android SDK Command-line Tools** & Platform Tools (API level 34+).
   - Set environment variables:
     - `JAVA_HOME` pointing to your JDK 17 folder.
     - `ANDROID_HOME` pointing to your Android SDK folder.

### Setup Instructions
```bash
# 1. Clone the repository
git clone https://github.com/kdaledavid24-max/arCUP-s.git

# 2. Navigate to project root
cd arCUP-s

# 3. Fetch dependencies
flutter pub get

# 4. Verify code quality and run tests
flutter analyze
flutter test

# 5. Run on connected device, emulator, or Chrome
flutter run

# 6. Build release Android APK
flutter build apk --release
```
The generated APK will be output to:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 Project Structure

```
arCUP-s/
├── .github/
│   └── workflows/
│       └── build_apk.yml          # Automated CI/CD Android APK build & release
├── android/                       # Native Android gradle configuration & manifest
│   └── app/
│       ├── build.gradle.kts       # Android app build specification & debug signing
│       └── src/main/
│           └── AndroidManifest.xml # Permissions & launcher metadata
├── assets/
│   └── images/                    # Local menu photography (drinks, pasta, salad)
├── lib/
│   ├── data/                      # Initial product seeds and sample menu items
│   ├── models/                    # Data models (Product, CartItem, Order, User)
│   ├── providers/                 # State management providers
│   ├── screens/                   # Customer screens (Home, Cart, Orders, Details)
│   │   └── admin/                 # Admin screens (Dashboard, Products, Sales, Users)
│   ├── services/                  # Local storage and persistence services
│   └── widgets/                   # Reusable UI widgets & universal image loader
├── test/                          # Unit and widget test suite (9/9 passing)
├── pubspec.yaml                   # Dependencies, assets, and project metadata
└── README.md                      # Project documentation & installation guide
```

---

## 🌐 GitHub Repository & Remote
- **GitHub URL**: [https://github.com/kdaledavid24-max/arCUP-s](https://github.com/kdaledavid24-max/arCUP-s)
- **Releases**: [https://github.com/kdaledavid24-max/arCUP-s/releases](https://github.com/kdaledavid24-max/arCUP-s/releases)

---

## 📄 License
This project is developed for educational purposes as part of the Electives Food Ordering Coursework. All rights reserved.
