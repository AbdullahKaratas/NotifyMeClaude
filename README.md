# NotifyMe Claude

A minimal reminder app for iOS that receives reminders from Claude Code.

## Architecture

```
Claude Code ──curl──► Supabase ──realtime──► Flutter App ──► Push Notification
```

## Setup

### 1. Supabase Setup

1. Create account at [supabase.com](https://supabase.com)
2. Create a new project
3. Go to SQL Editor and run the contents of `supabase/schema.sql`
4. Go to Database > Replication and enable replication for `reminders` table
5. Go to Settings > API and copy:
   - Project URL
   - `anon` public key

### 2. Configure the App

Edit `lib/config.dart`:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 3. Configure the Remind Script

Edit `scripts/remind.sh`:

```bash
SUPABASE_URL="https://YOUR_PROJECT.supabase.co"
SUPABASE_KEY="YOUR_ANON_KEY"
```

Then add to your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/NotifyMeClaude/scripts"
```

### 4. Build & Deploy

```bash
# Get dependencies
flutter pub get

# Run on iOS Simulator
flutter run

# Build for iOS device
flutter build ios --release
```

## Usage

### From Claude Code

```bash
# Basic reminder (tomorrow 9:00)
remind "Call mom"

# With specific time
remind "Meeting prep" "today 14:00"
remind "Review PR" "tomorrow 10:00"

# Relative time
remind "Take a break" "+30m"
remind "Lunch" "+2h"
remind "Weekly review" "+1d"
```

### In the App

- **Swipe right**: Mark as done
- **Swipe left**: Delete
- Reminders sync in realtime via Supabase

## Deployment to iPhone (without Developer Account)

### Option A: AltStore (Recommended)

1. Install [AltServer](https://altstore.io) on Mac/PC
2. Install AltStore on iPhone via AltServer
3. Build IPA: `flutter build ios --release --no-codesign`
4. Import IPA into AltStore

### Option B: Xcode with Free Apple ID

1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to Signing & Capabilities
3. Select your Personal Team (free Apple ID)
4. Connect iPhone and Build

Note: With free Apple ID, app expires after 7 days and needs reinstall.

## Project Structure

```
lib/
├── main.dart              # App entry point
├── config.dart            # Supabase credentials
├── models/
│   └── reminder.dart      # Reminder data model
├── services/
│   ├── supabase_service.dart    # API communication
│   └── notification_service.dart # Local notifications
├── screens/
│   └── home_screen.dart   # Main reminder list
└── widgets/
    └── reminder_tile.dart # Reminder card widget

scripts/
└── remind.sh              # CLI script for Claude Code
```
