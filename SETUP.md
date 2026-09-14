# Setup Guide

## Installation & Development Environment

### Prerequisites

- **Android 12+** (GrapheneOS recommended for maximum privacy)
- **Android Studio** (Arctic Fox or newer)
- **Android SDK** (API level 31+)
- **Kotlin** (1.7+)
- **ADB** (Android Debug Bridge) for Device Owner provisioning
- **Git**

### Step 1: Clone Repository

```bash
git clone https://github.com/ciphr-pixel78/burn-android.git
cd burn-android
```

### Step 2: Open in Android Studio

1. Launch Android Studio
2. Click **File → Open**
3. Navigate to the cloned `burn-android` directory
4. Let Gradle sync complete

### Step 3: Configure Build

Update `local.properties` if needed:

```properties
sdk.dir=/path/to/android/sdk
```

### Step 4: Build the App

```bash
./gradlew build
```

Or in Android Studio: **Build → Make Project**

---

## Device Owner Provisioning

**Critical:** Burn requires Device Owner permissions to perform factory resets and deep device wipes. This requires ADB setup on your device.

### Why Device Owner?

Device Owner mode allows the app to:
- ✅ Trigger factory reset without user confirmation
- ✅ Wipe data even when device is locked
- ✅ Control device admin policies
- ✅ Execute emergency data destruction

### Prerequisites for Device Owner Setup

1. **Enable Developer Options**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Developer Options now visible in Settings

2. **Enable USB Debugging**
   - Settings → Developer Options → USB Debugging
   - Toggle ON
   - Authorize your computer when prompted

3. **ADB Access**
   - Connect device to computer via USB
   - Test: `adb devices` (device should appear)

### Provisioning Burn as Device Owner

**Option A: Fresh Device Setup (Recommended)**

If starting with a fresh GrapheneOS installation:

```bash
# 1. Connect device via USB
# 2. Enable Developer Options & USB Debugging

# 3. Run provisioning command
adb shell dpm set-device-owner com.burn/.receiver.DeviceAdminReceiver
```

**Option B: Existing Device (Requires Factory Reset)**

If device already has Device Owner app or MDM:

```bash
# 1. Factory reset device
# 2. During initial setup, DON'T complete it
# 3. Connect via USB
# 4. Run provisioning command

adb shell dpm set-device-owner com.burn/.receiver.DeviceAdminReceiver
```

### Verification

Check if provisioning succeeded:

```bash
adb shell dpm get-device-owner
# Should output: com.burn/.receiver.DeviceAdminReceiver
```

### Install on Device

After provisioning:

```bash
# Build debug APK
./gradlew installDebug

# Or use Android Studio: Run → Run 'app'
```

### What Happens After Provisioning

- Burn becomes a system-level security app
- ✅ Can trigger factory reset
- ✅ Can wipe data without confirmation
- ✅ Persists through most attacks
- ⚠️ Cannot be uninstalled normally (requires ADB or factory reset)

---

## Configuration

### Initial Setup in App

1. **Launch Burn**
2. **Grant Permissions**
   - Device admin permissions
   - Lock screen monitoring
   - USB detection
3. **Configure Triggers**
   - Set wipe mode (Fast Wipe / Factory Reset)
   - Enable/disable triggers
   - Set PIN attempt limit
4. **Set Duress Password** (Optional)
   - Choose hidden PIN
   - Test in safe environment first

### Settings File

Configuration stored in encrypted SharedPreferences:

```
/data/data/com.burn/shared_prefs/burn_settings.xml
```

**Never edit directly.** Use app UI or adb shell:

```bash
# View settings (requires app running)
adb shell dumpsys package com.burn

# Clear all settings (emergency)
adb shell pm clear com.burn
```

---

## Development Workflow

### Building Different Variants

```bash
# Debug build (for testing)
./gradlew assembleDebug

# Release build (production)
./gradlew assembleRelease

# Run tests
./gradlew test
```

### Logging & Debugging

Enable logcat filtering:

```bash
# Watch Burn logs only
adb logcat | grep "BurnApp"

# Or in Android Studio: Logcat panel with filter "BurnApp"
```

### Testing Wipe Functions (CAREFULLY)

```bash
# Test Fast Wipe (safe on test device)
adb shell am start -n com.burn/.MainActivity -a "com.burn.WIPE_FAST"

# Test Factory Reset (WARNING: DESTRUCTIVE)
adb shell am start -n com.burn/.MainActivity -a "com.burn.WIPE_FACTORY"
```

### Device Owner Commands Reference

```bash
# Get current Device Owner
adb shell dpm get-device-owner

# Remove Device Owner (requires adb shell dpm)
adb shell dpm clear-device-owner-app

# Set Device Owner from APK
adb install-multiple app.apk
adb shell dpm set-device-owner com.burn/.receiver.DeviceAdminReceiver

# Reboot device
adb reboot

# Factory reset via adb (simulates Burn trigger)
adb shell am broadcast -a android.intent.action.MASTER_CLEAR
```

---

## GrapheneOS-Specific Notes

### Compatibility

Burn is designed to work with GrapheneOS's hardened security model:

✅ **Works Well:**
- Sandboxed permissions system
- No Google Play Services dependency
- SELinux policies
- Hardware-backed keystore
- Storage scopes

⚠️ **Limitations:**
- GrapheneOS restricts some Device Owner powers
- Factory reset may require manual confirmation in some cases
- USB restrictions may prevent some data theft attempts

### Recommended GrapheneOS Settings

For maximum Burn effectiveness:

```
Settings → Privacy → 
  ✅ Deny all app requests for:
    - Location
    - Camera
    - Microphone
    - Contacts
    - Calendar
  ✅ Disable WiFi scanning
  ✅ Disable Bluetooth scanning
  ✅ Disable analytics

Settings → Security →
  ✅ Enable encrypted storage
  ✅ Enable secure startup
  ✅ Set lockdown timer to minimum
```

---

## Troubleshooting

### Device Owner Setup Fails

**Error:** `Error setting device owner: not an admin`

```bash
# Solution: Manually register as device admin first
adb shell dpm set-active-admin com.burn/.receiver.DeviceAdminReceiver
```

**Error:** `Device owner can only be set before user setup`

```bash
# Solution: Factory reset and set up during initial setup
# OR use NFC provisioning for fresh installs
```

### Wipe Not Triggering

```bash
# Check if app has Device Owner
adb shell dpm get-device-owner

# Check if USB detection service is running
adb shell dumpsys com.burn

# Restart the monitoring service
adb shell am startservice com.burn/.services.LockscreenMonitor
```

### App Crashes on Startup

```bash
# View crash logs
adb logcat | grep "AndroidRuntime"

# Check for permission errors
adb logcat | grep "BurnApp"

# Rebuild and reinstall
./gradlew clean installDebug
```

### Can't Uninstall App

**This is expected** — Device Owner apps can't be uninstalled normally.

```bash
# To remove Device Owner (requires adb):
adb shell dpm remove-active-admin com.burn/.receiver.DeviceAdminReceiver

# Then uninstall
adb uninstall com.burn
```

---

## Next Steps

1. ✅ Clone repository
2. ✅ Set up development environment
3. ✅ Build app
4. ✅ Provision Device Owner
5. 📖 Read [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines
6. 📖 Review [ARCHITECTURE.md](./ARCHITECTURE.md) for code structure

---

## Security Reminders

⚠️ **Important:**

- Device Owner provisioning grants **deep system permissions**
- Only provision on devices you fully trust
- Wipe operations are **irreversible**
- Test on a secondary device first
- Never set wipe triggers unless you understand consequences
- Keep recovery codes/backups before enabling auto-wipe triggers
