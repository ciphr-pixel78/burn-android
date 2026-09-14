# Burn Android

A GrapheneOS-compatible privacy-focused mobile security app with on-device protection triggers, secure data wiping, and anti-surveillance features.

## Overview

Burn provides instant device protection when your phone is lost, seized, or you're forced to unlock it. No tracking, no accounts, no personal data required. Everything runs on-device with secure, configurable wipe options.

### Core Features (MVP)

- **Quick Burn Tile** — One-tap wipe from Quick Settings
- **Duress Password Mode** — Hidden PIN that triggers protection instead of unlocking
- **Failed PIN Attempts Wipe** — Auto-wipe after N incorrect unlock attempts
- **USB Data Burn** — Detect and wipe when data cable connected to locked device
- **Dual Wipe Modes**:
  - Fast Wipe: Secure deletion of sensitive app data (seconds)
  - Full Factory Reset: Complete device wipe (slower, total data destruction)
- **Device Owner Capable** — Runs as Device Owner for deep system access

### Privacy First

- ✅ No tracking, no ad-tech, no analytics
- ✅ Everything evaluated on-device
- ✅ GrapheneOS optimized (no Google Play Services required)
- ✅ No account signup required
- ✅ Optional secure cloud backup (anonymous)

## Getting Started

### Prerequisites

- Android 12+ (GrapheneOS recommended)
- ADB (Android Debug Bridge) for Device Owner setup
- Android Studio (for development)
- Kotlin/Java development environment

### Setup Instructions

See [SETUP.md](./SETUP.md) for detailed installation and Device Owner provisioning steps.

### Development

See [ARCHITECTURE.md](./ARCHITECTURE.md) for system design and [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines.

## Project Structure

```
burn-android/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── AndroidManifest.xml
│   │   │   ├── java/com/burn/
│   │   │   │   ├── MainActivity.kt
│   │   │   │   ├── services/
│   │   │   │   │   ├── WipeService.kt
│   │   │   │   │   ├── LockscreenMonitor.kt
│   │   │   │   │   └── DeviceOwnerManager.kt
│   │   │   │   ├── utils/
│   │   │   │   │   └── SecureWipe.kt
│   │   │   │   └── ui/
│   │   │   └── res/
│   ├── build.gradle.kts
│   └── proguard-rules.pro
├── build.gradle.kts
├── settings.gradle.kts
├── ARCHITECTURE.md
├── SETUP.md
├── CONTRIBUTING.md
└── LICENSE (GPL-3.0)
```

## Security Considerations

- Device Owner mode requires ADB setup — users grant deep system permissions
- Wipe operations are irreversible
- No recovery or "undo" — by design
- All sensitive operations logged only locally
- No external communication without explicit user configuration

## License

GPL-3.0 — See LICENSE file for details

## Roadmap

- [x] Project setup
- [ ] Device Owner provisioning
- [ ] Fast Wipe implementation
- [ ] Full Factory Reset implementation
- [ ] Quick Settings Tile
- [ ] Duress Password Mode
- [ ] Failed PIN monitoring
- [ ] USB detection
- [ ] Settings & Configuration UI
- [ ] Cloud backup (optional)
- [ ] Testing & hardening
- [ ] GrapheneOS compatibility verification

## Support

For issues, questions, or contributions, open an issue or pull request on GitHub.

---

**Remember:** Burn is powerful. Use it responsibly. Wipe operations are permanent.
