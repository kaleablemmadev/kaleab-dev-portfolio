# iOS Build Guide for Misol Calendar

This guide provides step-by-step instructions for building the Misol Calendar app for iOS on a MacBook after transferring the code from Windows.

## Prerequisites

### Required Software
- **macOS**: Monterey (12.0) or later
- **Xcode**: 14.0 or later (download from Mac App Store)
- **CocoaPods**: `sudo gem install cocoapods`
- **Flutter SDK**: 3.0.0 or later
- **Git**: For version control

### Apple Developer Account
- **Free Account**: For testing on your own device (7-day limit)
- **Paid Account ($99/year)**: For App Store distribution and extended testing

## Step-by-Step Build Instructions

### 1. Transfer Project to MacBook

**Option A: Using Git**
```bash
# On Windows (if using Git)
git add .
git commit -m "Prepare for iOS build"
git push origin main

# On MacBook
git clone <your-repo-url>
cd misol
```

**Option B: Using File Transfer**
- Copy the entire `misol` folder via USB drive, cloud storage (Dropbox, Google Drive), or network transfer
- Ensure all hidden files (`.git`, `.flutter-plugins-dependencies`, etc.) are included

### 2. Install Flutter on MacBook

```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

### 3. Install Required Dependencies

```bash
# Navigate to project directory
cd ~/path/to/misol

# Get Flutter dependencies
flutter pub get

# Install iOS dependencies (CocoaPods)
cd ios
pod install
cd ..
```

### 4. Configure Xcode

```bash
# Open project in Xcode
open ios/Runner.xcworkspace
```

**In Xcode:**
1. Select **Runner** in the project navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Add your Apple Developer team
5. Enable **Automatically manage signing**

### 5. Configure Bundle Identifier

**For Free Account:**
- Bundle Identifier: `com.yourname.misol`
- Must be unique across all apps

**For Paid Account:**
- Bundle Identifier: `com.yourcompany.misol`
- Register in Apple Developer Console

### 6. Update Deployment Target

The project is configured for iOS 13.0+. Verify in Xcode:
- **General** tab → **Deployment Info** → **Minimum Deployments**: iOS 13.0

### 7. Build and Run on Simulator

```bash
# List available simulators
flutter devices

# Run on simulator
flutter run -d <device-id>

# Or use Xcode
# Select simulator from device list
# Press ⌘R to run
```

### 8. Build for Physical Device

#### Step 1: Connect Device
- Connect iPhone/iPad via USB
- Trust the computer on your device
- Verify device is detected: `flutter devices`

#### Step 2: Configure Provisioning Profile
- In Xcode, select your physical device
- Go to **Signing & Capabilities**
- Ensure your team is selected
- Xcode will automatically create provisioning profile

#### Step 3: Build and Run
```bash
flutter run -d <your-device-id>
```

### 9. Build for App Store Distribution

#### Step 1: Update Version Numbers
In `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+build-number
```

#### Step 2: Archive in Xcode
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select **Any iOS Device (arm64)**
3. **Product** → **Archive**
4. Wait for archive to complete

#### Step 3: Upload to App Store Connect
1. In Organizer window, select your archive
2. Click **Distribute App**
3. Select **App Store Connect**
4. Follow the prompts to upload

## Common Issues and Solutions

### CocoaPods Installation Issues
```bash
# Update CocoaPods
sudo gem install cocoapods

# Clear CocoaPods cache
pod cache clean --all

# Reinstall pods
cd ios
rm -rf Pods Podfile.lock
pod install
```

### Flutter Doctor Issues
```bash
# Run flutter doctor for detailed diagnostics
flutter doctor -v

# Accept Android licenses (if needed)
flutter doctor --android-licenses
```

### Signing Issues
- Ensure you have a valid Apple Developer account
- Check that Bundle Identifier is unique
- Verify your team is selected in Xcode
- Try deleting derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### Build Errors
```bash
# Clean build folder
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter pub get
```

### Permission Errors
The app requires these permissions (configured in Info.plist):
- **Notifications**: For event reminders
- **Local Network**: For connectivity monitoring
- **Calendar Access**: Optional, for iOS calendar sync

## Testing Checklist

Before submitting to App Store:

- [ ] Test on iOS 13.0, 14.0, 15.0, 16.0, 17.0
- [ ] Test on iPhone and iPad (if supported)
- [ ] Test notifications (foreground and background)
- [ ] Test offline functionality
- [ ] Test app persistence after restart
- [ ] Verify all permissions are requested properly
- [ ] Test on different screen sizes
- [ ] Verify app icon and launch screen

## App Store Submission Requirements

1. **Screenshots**: Required for each device size (6.7", 6.5", 5.5" iPhone, 12.9" iPad)
2. **App Icon**: 1024x1024px PNG
3. **Privacy Policy URL**: Required if app collects data
4. **App Category**: Choose appropriate category (Productivity)
5. **Age Rating**: Complete content rating questionnaire
6. **Export Compliance**: Answer encryption questions

## Performance Optimization

### Reduce App Size
```bash
# Analyze app size
flutter build ios --release --analyze-size

# Use ProGuard (Android) or bitcode (iOS)
# Already configured in Podfile
```

### Build Performance
```bash
# Use build cache
flutter build ios --release

# Enable build cache in Xcode
# Xcode → Preferences → Behaviors → Build
```

## Continuous Integration (Optional)

For automated builds, consider:
- **GitHub Actions**: Free for public repos
- **Bitrise**: Specialized for mobile apps
- **Codemagic**: Flutter-focused CI/CD

## Support Resources

- **Flutter iOS Documentation**: https://flutter.dev/docs/development/ios
- **Apple Developer Documentation**: https://developer.apple.com/documentation/
- **Flutter Community**: https://flutter.dev/community
- **Stack Overflow**: Tag with `flutter` and `ios`

## Notes for This Project

### Package-Specific Configurations
- **flutter_local_notifications**: Configured in AppDelegate.swift
- **connectivity_plus**: Requires local network permission
- **timezone**: Requires iOS 13.0+
- **shared_preferences**: Works out of the box
- **permission_handler**: Configured in Info.plist

### Custom Configurations
- **Deployment Target**: iOS 13.0 (Podfile)
- **Background Modes**: Audio, fetch, remote-notification, processing
- **Audio Session**: Playback mode for ringtones
- **App Transport Security**: Allows arbitrary loads for offline-first architecture

## Quick Reference Commands

```bash
# Clean everything
flutter clean && cd ios && pod deintegrate && pod install && cd ..

# Run on specific device
flutter run -d iPhone

# Build release
flutter build ios --release

# Check devices
flutter devices

# Update pods
cd ios && pod update && cd ..

# Open in Xcode
open ios/Runner.xcworkspace
```

## Contact

For issues specific to this project, refer to the README.md or contact the development team.
