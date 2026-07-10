# ResumeAI Pro — Flutter App 🚀

ATS-Optimized AI Resume Builder — Flutter Android App

---

## ⚡ Setup Steps

### Step 1 — Flutter Install
https://docs.flutter.dev/get-started/install/windows

### Step 2 — Backend URL set karo
`lib/services/api_service.dart` mein line #8 update karo:

```dart
// Android Emulator use kar rahe ho:
static const String baseUrl = 'http://10.0.2.2:8000';

// Real phone (same WiFi):
// CMD mein `ipconfig` se apna IPv4 nikalo
static const String baseUrl = 'http://192.168.1.XX:8000';

// Production (Render.com deploy ke baad):
static const String baseUrl = 'https://your-app.onrender.com';
```

### Step 3 — Dependencies install
```bash
flutter pub get
```

### Step 4 — Backend chalao (alag terminal mein)
```bash
set ANTHROPIC_API_KEY=sk-ant-xxxxxxx
cd resume-app/backend
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Step 5 — App run karo
```bash
# Emulator ya phone connect karke:
flutter run

# APK build karne ke liye:
flutter build apk --release
# APK milega: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme.dart                   # Colors, theme, shared widgets
├── models/
│   └── resume_model.dart        # Data classes
├── services/
│   └── api_service.dart         # Backend API calls
├── screens/
│   ├── landing_screen.dart      # Home screen
│   ├── form_screen.dart         # Data entry form
│   ├── verify_screen.dart       # Data verification
│   ├── payment_screen.dart      # Plan & payment
│   ├── building_screen.dart     # AI generation animation
│   └── result_screen.dart       # Resume + chat editor
└── widgets/
    └── resume_preview.dart      # Resume render widget

android/
├── app/
│   ├── build.gradle
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── kotlin/.../MainActivity.kt
│       └── res/
│           ├── drawable/launch_background.xml
│           └── values/styles.xml
├── build.gradle
├── gradle.properties
└── settings.gradle
```

---

## 🔌 Backend Required
Ye app FastAPI backend ke saath kaam karta hai.
Backend folder: `resume-app/backend/main.py`

---

## 💰 Pricing Logic
- 0–3 years experience → Junior Plan ₹20
- 4+ years → Senior Plan ₹50
- 3 free edits included
- 4th edit onwards ₹10 extra

---

## 📦 Dependencies
```yaml
http: ^1.2.0
google_fonts: ^6.1.0
flutter_animate: ^4.3.0
path_provider: ^2.1.2
open_file: ^3.3.2
share_plus: ^7.2.1
shared_preferences: ^2.2.2
file_picker: ^6.1.1
```
