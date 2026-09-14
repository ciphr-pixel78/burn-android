# Contributing

## Development Guidelines

Thank you for contributing to Burn! This document outlines development practices, code standards, and workflow.

## Code of Conduct

- Respect user privacy above all else
- No tracking, analytics, or telemetry
- No third-party dependencies that violate privacy
- Security-first mindset in all decisions

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Follow code standards (see below)
4. Test thoroughly on GrapheneOS
5. Submit a pull request

## Code Standards

### Kotlin Style Guide

**Naming:**
```kotlin
// Classes: PascalCase
class WipeService

// Functions: camelCase
fun performFastWipe()

// Constants: UPPER_SNAKE_CASE
const val MAX_PIN_ATTEMPTS = 10

// Private members: _camelCase
private val _internalState = mutableStateOf(false)
```

**Formatting:**
- Max line length: 120 characters
- Use 4-space indentation
- One statement per line
- Meaningful variable names

```kotlin
// Good
fun handleFailedAttempt(attemptCount: Int, maxAttempts: Int) {
    if (attemptCount >= maxAttempts) {
        triggerWipe()
    }
}

// Avoid
fun h(a: Int, m: Int) {
    if (a >= m) w()
}
```

### Security-Critical Code

Extra scrutiny for:
- `SecureWipe.kt` — All wipe operations
- `DeviceOwnerManager.kt` — Device Owner API calls
- `LockscreenMonitor.kt` — Trigger detection
- Any cryptographic operations

**Requirements:**
- Detailed comments explaining security rationale
- No hardcoded secrets
- Validate all inputs
- Handle exceptions gracefully
- Test extensively

### Comments & Documentation

```kotlin
/**
 * Performs secure deletion of app data.
 * 
 * Uses multiple overwrite passes to ensure data cannot be recovered.
 * This is the "fast wipe" mode - completes in seconds.
 * 
 * @throws SecurityException if Device Owner permissions missing
 */
fun secureDeleteAppData(): Boolean {
    // First pass: overwrite with zeros
    // Second pass: overwrite with random data
    // Third pass: final overwrite
}
```

## Testing

### Unit Tests

```bash
./gradlew test
```

**Test files location:** `app/src/test/`

**Test naming:** `{ClassName}Test.kt`

```kotlin
class SecureWipeTest {
    
    @Test
    fun testFastWipeDeletesAppData() {
        // Setup
        val wipe = SecureWipe()
        
        // Execute
        val result = wipe.secureDeleteAppData()
        
        // Assert
        assertTrue(result)
    }
}
```

### Integration Tests

```bash
./gradlew connectedAndroidTest
```

**Test files location:** `app/src/androidTest/`

**Device Owner tests:** Run only on provisioned devices

```kotlin
@RunWith(AndroidJUnit4::class)
class DeviceOwnerTest {
    
    @Test
    fun testFactoryResetPermission() {
        val deviceOwner = DeviceOwnerManager(context)
        assertTrue(deviceOwner.isDeviceOwner())
    }
}
```

### Manual Testing Checklist

Before submitting PR:

- [ ] App launches successfully
- [ ] Settings persist after reboot
- [ ] Quick Burn tile appears in Quick Settings
- [ ] Wipe triggers execute (test on safe device)
- [ ] No crashes in logcat
- [ ] No permission warnings
- [ ] Works on GrapheneOS

## Commits & PRs

### Commit Message Format

```
[Type] Brief description (50 chars max)

Detailed explanation of changes (wrap at 72 chars).
Explain WHY, not just WHAT.

Related to: #123 (if applicable)
```

**Types:**
- `[feat]` New feature
- `[fix]` Bug fix
- `[security]` Security-related change
- `[refactor]` Code restructuring
- `[test]` Tests
- `[docs]` Documentation
- `[chore]` Build, dependencies, etc.

**Examples:**
```
[feat] Add Duress Password Mode

Implement hidden PIN trigger that silently wipes device
when entered at lockscreen. Appears as normal unlock to
attacker while triggering configured wipe in background.

Related to: #42
```

```
[security] Fix hardcoded API key in settings

Remove hardcoded encryption key from SharedPreferences.
Now uses device-backed KeyStore for secure storage.

Fixes: #128
```

### Pull Request Template

```markdown
## Description
Brief explanation of changes

## Motivation
Why is this change needed?

## Changes
- Bullet 1
- Bullet 2

## Testing
How did you test this?

## Security Considerations
Any security implications?

## Checklist
- [ ] Code follows style guide
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Tested on GrapheneOS
- [ ] No privacy violations
- [ ] No new dependencies (or justified)
```

## Privacy Requirements

**Any PR must:**

1. ✅ Not add tracking/analytics
2. ✅ Not require user accounts
3. ✅ Not send data to external servers (without explicit opt-in)
4. ✅ Not add Google Play Services dependency
5. ✅ Not request unnecessary permissions
6. ✅ Include justification if exceptions needed

## Dependencies

**Adding New Dependencies:**

1. Justify necessity (no bloat)
2. Check for privacy violations (no trackers)
3. Verify GrapheneOS compatibility
4. Add to `build.gradle.kts` with explicit version
5. Document in PR

**Restricted:**
- ❌ Google Play Services
- ❌ Firebase/Analytics
- ❌ Ad libraries
- ❌ Tracking SDKs
- ❌ Telemetry

**Approved Libraries:**
- Jetpack (AndroidX)
- Kotlin coroutines
- OkHttp (no telemetry)
- Bouncy Castle (cryptography)

## Release Process

1. Create release branch: `release/v1.x.x`
2. Update version in `build.gradle.kts`
3. Update `CHANGELOG.md`
4. Tag: `git tag v1.x.x`
5. Create GitHub release with changelog

## Issues & Bug Reports

**Reporting Bugs:**

```markdown
## Description
What happened?

## Reproduction
Steps to reproduce:
1. ...
2. ...

## Expected
What should happen?

## Actual
What actually happened?

## Environment
- Device: (GrapheneOS/Stock Android)
- Android version: X.X
- Burn version: X.X.X

## Logs
```
adb logcat | grep BurnApp
```
```

**Before submitting:**
- [ ] Check existing issues
- [ ] Include reproducible steps
- [ ] Include device/environment details
- [ ] Include relevant logs

## Feature Requests

```markdown
## Feature
Brief description

## Use Case
Why is this needed?

## Proposed Solution
How should it work?

## Alternatives
Other approaches?

## Privacy Impact
Does it violate privacy principles?
```

## Documentation

### Updating Docs

- `README.md` — Overview, features
- `ARCHITECTURE.md` — System design
- `SETUP.md` — Installation
- `CONTRIBUTING.md` — This file
- `CHANGELOG.md` — Version history

**When to update:**
- New feature → Update README + ARCHITECTURE
- New component → Update ARCHITECTURE
- Setup changes → Update SETUP.md
- Release → Update CHANGELOG

## Questions?

- Open an issue for discussion
- Review existing issues/PRs
- Check discussions tab

---

**Thank you for contributing to Burn!**

Remember: Security, privacy, and simplicity are our core values.
