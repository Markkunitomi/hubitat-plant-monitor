# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2025-01-12

### Fixed
- **API Connection**: Fixed Hubitat Maker API endpoint format to use correct URL structure (`/apps/api/[APP_ID]/devices?access_token=token`)
- **Data Parsing**: Fixed device ID parsing to handle string IDs returned by Hubitat API
- **Attribute Reading**: Fixed moisture value parsing to handle both string and numeric attribute values
- **Sensor Detection**: Added support for Ecowitt RF sensors that use "humidity" attribute for soil moisture
- **UI**: Removed empty window that appeared on app launch - now properly menu bar-only

### Technical
- Updated API client to use query parameter format for access tokens
- Added robust JSON parsing for mixed data types (string/numeric IDs and values)
- Enhanced attribute detection to support both "moisture" and "humidity" attributes
- Improved error handling for network responses

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