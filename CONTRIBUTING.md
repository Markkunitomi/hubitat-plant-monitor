# Contributing to Hubitat Plant Monitor

Thank you for your interest in contributing! This project welcomes contributions from the community.

## How to Contribute

### Reporting Issues
- **Bug Reports**: Use the issue tracker to report bugs
- **Feature Requests**: Suggest new features or improvements
- **Questions**: Ask questions about setup or usage

When reporting issues, please include:
- macOS version
- Xcode version (if building from source)
- Hubitat hub model and firmware version
- Steps to reproduce the issue
- Expected vs actual behavior

### Development Setup

1. **Prerequisites**:
   - macOS 13.0 or later
   - Xcode 15.0 or later
   - Swift 5.0+

2. **Clone and Build**:
   ```bash
   git clone https://github.com/[username]/hubitat-plant-monitor.git
   cd hubitat-plant-monitor
   open HubitatSensor.xcodeproj
   ```

3. **Test Setup**:
   - Ensure you have a Hubitat hub with moisture sensors
   - Configure Maker API with test devices
   - Test all features before submitting changes

### Code Guidelines

#### Swift Style
- Follow Apple's Swift API Design Guidelines
- Use SwiftLint for code formatting (if configured)
- Prefer explicit types when clarity is improved
- Use meaningful variable and function names

#### Architecture
- **MVVM pattern** for UI components
- **Singleton pattern** for API and Keychain helpers
- **Async/await** for network operations
- **Combine** or **@State** for reactive UI updates

#### Security
- **Never commit credentials** or sensitive data
- **Use Keychain** for secure storage
- **Validate all user inputs**
- **Handle errors gracefully**

### Pull Request Process

1. **Fork** the repository
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the code guidelines
4. **Test thoroughly** on your own setup
5. **Update documentation** if needed
6. **Submit a pull request** with:
   - Clear description of changes
   - Screenshots/videos if UI changes
   - Testing steps performed

#### PR Requirements
- [ ] Code builds without warnings
- [ ] All existing functionality still works
- [ ] New features are properly tested
- [ ] Documentation updated if needed
- [ ] No sensitive data committed

### Types of Contributions Welcome

#### Features
- **Additional sensor types** (temperature, humidity, etc.)
- **Data visualization** (charts, graphs)
- **Notifications** (push notifications, sounds)
- **Export capabilities** (CSV, JSON data export)
- **Scheduling** (watering reminders, schedules)

#### Improvements
- **Performance optimizations**
- **UI/UX enhancements**
- **Error handling improvements**
- **Accessibility features**
- **Localization** (additional languages)

#### Documentation
- **Setup tutorials** with screenshots
- **Video guides** for configuration
- **FAQ** based on common issues
- **API documentation** improvements

### Development Notes

#### Project Structure
```
HubitatSensor/
├── AppDelegate.swift          # App lifecycle
├── MenuBarController.swift    # Main UI controller
├── HubitatAPI.swift          # API client
├── SensorModels.swift        # Data models
├── PreferencesWindow.swift   # Settings UI
├── KeychainHelper.swift      # Secure storage
└── Assets.xcassets/          # Icons and assets
```

#### Key Classes
- **HubitatAPI**: Manages all hub communication
- **MenuBarController**: Handles menu bar UI and user interactions
- **SensorModels**: Data structures and app settings
- **KeychainHelper**: Secure credential storage

#### Testing Strategy
- **Manual testing** with real Hubitat hardware
- **Network error simulation** for robustness
- **UI testing** across different screen sizes
- **Performance testing** with multiple sensors

### Community

#### Communication
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Request Reviews**: Code discussion and feedback

#### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn and contribute
- Maintain a welcoming environment

### Release Process

#### Versioning
- Follow [Semantic Versioning](https://semver.org/)
- **Major**: Breaking changes
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes

#### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version number incremented
- [ ] Release notes written
- [ ] Tagged release created

## Questions?

Feel free to:
- Open an issue for questions
- Start a discussion for ideas
- Reach out to maintainers for guidance

Thank you for contributing to making plant care easier for the Hubitat community! 🌱