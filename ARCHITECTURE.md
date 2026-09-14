# Architecture

## System Design

Burn Android is built as a privacy-first, on-device protection system with clear separation between security-critical components and UI.

### Core Components

```
┌─────────────────────────────────────────────────────┐
│                   User Interface                     │
│  (MainActivity, Settings, Quick Tile, Notifications) │
└────────────┬────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────┐
│              Device Owner Manager                    │
│  (Provisioning, Permissions, Factory Reset API)     │
└────────────┬────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────┐
│           Security Service Layer                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  │ Wipe Service │  │Lock Monitor  │  │USB Detector  │
│  └──────────────┘  └──────────────┘  └──────────────┘
└────────────┬────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────┐
│            Secure Wipe Engine                        │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │ Fast Wipe    │  │Factory Reset │                  │
│  │ (App Data)   │  │ (Full Device)│                  │
│  └──────────────┘  └──────────────┘                  │
└─────────────────────────────────────────────────────┘
```

### Key Classes & Responsibilities

#### 1. **DeviceOwnerManager** (`services/DeviceOwnerManager.kt`)
- Manages Device Owner provisioning and status
- Checks if app has Device Owner permissions
- Handles factory reset API calls
- Communicates with DevicePolicyManager

**Key Methods:**
- `isDeviceOwner(): Boolean` — Check Device Owner status
- `requestDeviceOwnerSetup()` — Guide user through ADB setup
- `triggerFactoryReset()` — Call factory reset (requires Device Owner)
- `setDevicePassword(password: String)` — Set/update PIN

#### 2. **WipeService** (`services/WipeService.kt`)
- Orchestrates wipe operations
- Routes between Fast Wipe and Factory Reset
- Handles pre-wipe operations (logging, notifications)
- Manages wipe scheduling and execution

**Key Methods:**
- `performFastWipe()` — Secure deletion of app data
- `performFactoryReset()` — Full device wipe
- `scheduleWipeIfNeeded()` — Defer wipe if device in use

#### 3. **LockscreenMonitor** (`services/LockscreenMonitor.kt`)
- Monitors failed PIN attempts
- Detects USB connection while locked
- Tracks Duress Password activation
- Broadcasts wipe triggers to WipeService

**Key Methods:**
- `onFailedPinAttempt()` — Handle failed unlock attempt
- `onUsbConnected()` — Detect USB data connection
- `onDuressPasswordEntered()` — Detect special PIN

#### 4. **SecureWipe** (`utils/SecureWipe.kt`)
- Core secure deletion logic
- Implements secure overwrite patterns
- Handles file system operations
- Device Owner integration for deep wipes

**Key Methods:**
- `secureDeleteAppData()` — Wipe app caches & sensitive files
- `secureDeleteUserData(paths: List<String>)` — Wipe selected user data
- `secureDeleteSystemData()` — Clear system logs, caches
- `factoryResetDevice()` — Trigger full wipe via Device Owner

### Trigger System

Each trigger follows the same flow:

```
Trigger Event → LockscreenMonitor → Event Handler
                                   ↓
                          Verify Conditions Met
                                   ↓
                        WipeService.performWipe()
                                   ↓
                    Choose Wipe Mode (Fast/Factory)
                                   ↓
                        SecureWipe.execute()
                                   ↓
                          Wipe Complete
```

### Configuration & State

All user settings stored securely locally:

```
SharedPreferences (Encrypted):
├── wipe_mode (fast | factory)
├── duress_pin (hashed)
├── pin_attempt_limit
├── usb_wipe_enabled
├── failed_attempts_count
└── last_wipe_timestamp
```

### Permissions Required

```xml
<!-- Device Owner only (requires ADB setup) -->
<uses-permission android:name="android.permission.REBOOT" />
<uses-permission android:name="android.permission.MASTER_CLEAR" />

<!-- Normal permissions -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.DEVICE_POWER" />
<uses-permission android:name="android.permission.BIND_DEVICE_ADMIN" />

<!-- Hardware access -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.HARDWARE_TEST" />
```

### Data Flow: Quick Burn Tile

1. User taps Quick Settings tile
2. Confirmation dialog shown
3. `WipeService.performWipe()` called with configured mode
4. SecureWipe executes wipe operation
5. Notification sent (if device survives wipe)
6. Device reboots or shuts down

### Data Flow: Failed PIN Attempts

1. LockscreenMonitor receives keyguard callback
2. Attempt counter incremented
3. If counter ≥ limit:
   - Trigger WipeService
   - Execute configured wipe mode
   - Device wipes before attacker can retry

### Data Flow: USB Detection

1. BroadcastReceiver detects USB connection intent
2. Check device lock status
3. If locked + USB detected:
   - Trigger WipeService immediately
   - Full wipe before data transfer possible

### Duress Password Flow

1. User enters special PIN at lockscreen
2. System recognizes it as Duress PIN (via special handling)
3. Shows normal unlock confirmation
4. Silently triggers Factory Reset in background
5. Device appears to unlock normally, then wipes

### Security Considerations

**Threat Model:**
- Device is physically stolen/seized
- Attacker attempts forced unlock
- Attacker connects USB for data extraction
- Device owner needs deniable trigger

**Mitigations:**
- All triggers fire before attacker gains access
- No recovery possible after wipe (by design)
- Duress mode appears normal to coerce victim
- USB detection fires before data flow begins
- Fast Wipe prioritizes speed over thoroughness
- Factory Reset ensures nothing recoverable remains

**What We DON'T Do:**
- ❌ Track location
- ❌ Send data to servers
- ❌ Log to cloud
- ❌ Require user accounts
- ❌ Phone home on any trigger

### Development Priorities

1. **Phase 1**: Device Owner setup, basic factory reset
2. **Phase 2**: Fast Wipe implementation, SecureWipe utilities
3. **Phase 3**: LockscreenMonitor, USB detection, PIN attempts
4. **Phase 4**: UI, Quick Settings tile, Duress mode
5. **Phase 5**: Testing, hardening, GrapheneOS verification

