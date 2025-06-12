# Hubitat Moisture Sensor Mac Menu Bar Widget

A macOS menu bar application that displays moisture sensor data from your Hubitat hub, helping you keep track of your plants' watering needs.

## Features

### Core Functionality
- **Real-time monitoring**: Connects to Hubitat Maker API to fetch moisture sensor readings
- **Smart status indicators**: Menu bar icon changes color based on overall plant health
  - 🟢 Green: All plants healthy
  - 🟡 Yellow: Some plants need attention  
  - 🔴 Red: Plants critically dry
  - ⚪ Gray: Unknown status or not configured
- **Detailed sensor view**: Dropdown menu shows individual sensor information
- **Auto-refresh**: Configurable refresh intervals (5-120 minutes)
- **Background operation**: Runs silently in the menu bar

### Plant Management
- **Custom plant names**: Override device names with friendly plant names
- **"Just Watered" tracking**: Mark plants as recently watered to temporary override alerts
- **Moisture thresholds**: Configurable levels for when plants need attention
- **Battery monitoring**: Shows battery levels for wireless sensors

### Security & Configuration
- **Secure storage**: API credentials stored in macOS Keychain
- **Easy setup**: Guided configuration with connection testing
- **Error handling**: Clear error messages and recovery options

## Requirements

- macOS 13.0 or later
- Hubitat Elevation hub with Maker API enabled
- Moisture sensors connected to your Hubitat hub

## Installation

### Option 1: Build from Source
1. Open the project in Xcode 15 or later
2. Build and run the project (⌘+R)
3. The app will appear in your menu bar

### Option 2: Release Download
Download the latest release from the GitHub releases page (when available).

## Setup Instructions

### 1. Configure Hubitat Maker API

1. **Access your Hubitat hub**:
   - Open your web browser
   - Navigate to `http://[your-hub-ip]`

2. **Enable Maker API**:
   - Go to **Apps** → **Add Built-In App**
   - Select **Maker API**
   - Choose your moisture sensor devices
   - Click **Done**

3. **Get your API details**:
   - Click on the **Maker API** app you just created
   - Note your **Access Token** and **Cloud Endpoint URL**
   - Your hub IP is typically shown in the URL bar

### 2. Configure the Menu Bar App

1. **First launch**: Click the menu bar icon and select "Setup Required"
2. **Enter connection details**:
   - **Hub IP Address**: Your Hubitat hub's local IP (e.g., `192.168.1.100`)
   - **Maker API Token**: The access token from step 1
3. **Test connection**: Click "Test Connection" to verify settings
4. **Configure thresholds**:
   - **Healthy Threshold**: Moisture % below which plants need attention (default: 40%)
   - **Critical Threshold**: Moisture % below which plants are critical (default: 20%)
5. **Set refresh interval**: How often to check sensors (default: 30 minutes)

### 3. Customize Plant Names (Optional)

1. After successful connection, the preferences will show detected sensors
2. Enter custom names for your plants (e.g., "Kitchen Basil", "Living Room Fiddle Leaf")
3. These names will appear in the menu instead of device names

## Usage

### Menu Bar Icon
- **Click**: Refresh sensor data immediately
- **Icon color**: Indicates overall plant health status
- **Hover**: Shows tooltip with current status

### Dropdown Menu
- **Sensor list**: Shows all detected moisture sensors
- **Sensor details**: Click a sensor to see:
  - Current moisture percentage
  - Battery level (if available)
  - Last update time
  - Current status
- **Quick actions**: 
  - "Mark as Just Watered" for plants that need attention
  - "Clear Watered Status" to remove the watered flag

### Preferences
- **Access**: Click "Preferences..." in the dropdown menu
- **Update settings**: Modify thresholds, refresh intervals, and plant names
- **Test connection**: Verify API settings are working

## Troubleshooting

### Connection Issues
- **"Authentication failed"**: Check your API token is correct
- **"Network Error"**: Verify hub IP address and network connectivity
- **"No sensors found"**: Ensure moisture sensors are added to Maker API app

### Sensor Detection
The app automatically detects devices containing these keywords:
- "moisture" in device name or type
- "soil" in device type

If your sensors aren't detected, check they're included in your Maker API app configuration.

### Menu Bar Icon Not Appearing
- Check macOS menu bar settings in System Preferences
- Ensure the app has necessary permissions
- Try restarting the application

## Development

### Project Structure
```
HubitatSensor/
├── AppDelegate.swift          # Main app entry point
├── MenuBarController.swift    # Menu bar management
├── HubitatAPI.swift          # API client
├── SensorModels.swift        # Data models
├── PreferencesWindow.swift   # Settings UI
├── KeychainHelper.swift      # Secure storage
└── Assets.xcassets/          # App icons and assets
```

### Building
1. Clone this repository
2. Open `HubitatSensor.xcodeproj` in Xcode
3. Build and run (⌘+R)

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Privacy & Security

- **Local operation**: All data processing happens locally on your Mac
- **Secure storage**: API tokens stored in macOS Keychain
- **No telemetry**: No usage data or personal information is collected
- **Network access**: Only communicates with your local Hubitat hub

## Support

For issues, feature requests, or questions:
1. Check the troubleshooting section above
2. Search existing GitHub issues
3. Create a new issue with details about your setup

## License

MIT License - see LICENSE file for details.

---

**Happy Plant Parenting! 🌱**