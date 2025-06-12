# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-01-12

### Added
- Initial release of Hubitat Plant Monitor
- macOS menu bar application for monitoring moisture sensors
- Hubitat Maker API integration
- Color-coded status indicators (green/yellow/red/gray)
- Automatic sensor detection for moisture/soil sensors
- Configurable moisture thresholds
- Custom plant naming system
- "Just Watered" tracking functionality
- Secure keychain storage for API credentials
- Auto-refresh with configurable intervals (5-120 minutes)
- Preferences window with connection testing
- Background data fetching without UI blocking
- Battery level monitoring for wireless sensors
- Error handling with user-friendly messages
- Support for multiple moisture sensors
- Menu bar dropdown with detailed sensor information
- Manual refresh capability
- macOS 13.0+ compatibility
- App sandbox security model

### Security
- API tokens stored securely in macOS Keychain
- Local-only operation (no external data transmission)
- Secure HTTP communication with Hubitat hub
- App sandbox restrictions for enhanced security

## [Future Releases]

### Planned Features
- Push notifications for critical moisture levels
- Data export capabilities (CSV, JSON)
- Historical data charts and trends
- Support for additional sensor types (temperature, humidity)
- Watering schedule reminders
- Multiple hub support
- Dark mode support
- Accessibility improvements
- Localization for additional languages

---

**Note**: This changelog follows the format from [Keep a Changelog](https://keepachangelog.com/).
Each version documents changes in categories: Added, Changed, Deprecated, Removed, Fixed, and Security.