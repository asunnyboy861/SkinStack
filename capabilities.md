# Capabilities Configuration Guide

## Configuration Summary

### No Capabilities Required (Auto-Config via Info.plist)

| Capability | Status | Notes |
|------------|--------|-------|
| Camera Access | ✅ Configured via INFOPLIST_KEY | NSCameraUsageDescription added to build settings |
| Photo Library Access | ✅ Configured via INFOPLIST_KEY | NSPhotoLibraryUsageDescription added to build settings |
| Notifications | ✅ Runtime Request | UNUserNotificationCenter API, no capability needed |

**Why no explicit capabilities needed**: SkinStack uses Apple frameworks that only require Info.plist privacy descriptions (Camera for OCR scanning, Photo Library for skin journal photos) and runtime notification permission requests. No iCloud, no HealthKit, no Push Notifications capability, no App Groups needed.

**Verification**: Build succeeded with privacy descriptions configured ✅

## Auto-Configured Privacy Descriptions (✅ Success - No Action Needed)

### 1. Camera Access
**Status**: ✅ Successfully configured
**Configuration Details**:
- **Build Setting**: INFOPLIST_KEY_NSCameraUsageDescription = "SkinStack needs camera access to scan product ingredient labels."
- **Purpose**: Vision OCR ingredient scanning
- **Verification**: Build setting added to both Debug and Release configurations

### 2. Photo Library Access
**Status**: ✅ Successfully configured
**Configuration Details**:
- **Build Setting**: INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "SkinStack needs photo access to save skin journal photos."
- **Purpose**: Skin journal photo capture and progress tracking
- **Verification**: Build setting added to both Debug and Release configurations

### 3. Notifications
**Status**: ✅ Runtime-only (no capability needed)
**Configuration Details**:
- **Framework**: UserNotifications (UNUserNotificationCenter)
- **Purpose**: Wait-time timer completion reminders
- **Request**: Runtime authorization request via UNUserNotificationCenter.current().requestAuthorization()
- **Verification**: No build setting needed, handled in code

## Summary Checklist

- [x] Camera privacy description configured
- [x] Photo Library privacy description configured
- [x] Notifications handled at runtime
- [x] No manual capability configuration required
- [x] Build verification pending
