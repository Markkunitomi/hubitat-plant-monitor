import Cocoa
import SwiftUI

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private var sensors: [MoistureSensor] = []
    private var refreshTimer: Timer?
    private var isRefreshing = false
    private var preferencesWindow: NSWindow?
    
    override init() {
        super.init()
        setupMenuBar()
        setupMenu()
        startRefreshTimer()
        
        Task {
            await refreshData()
        }
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            updateMenuBarIcon(status: .unknown)
            button.action = #selector(menuBarButtonClicked)
            button.target = self
        }
    }
    
    private func setupMenu() {
        menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }
    
    private func updateMenuBarIcon(status: MoistureStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let button = self.statusItem.button else { return }
            
            let symbolName: String
            let tintColor: NSColor
            
            switch status {
            case .healthy, .justWatered:
                symbolName = "leaf.fill"
                tintColor = .white
            case .needsAttention:
                symbolName = "exclamationmark.triangle.fill"
                tintColor = .systemOrange
            case .critical:
                symbolName = "drop.fill"
                tintColor = .systemRed
            case .unknown:
                symbolName = "questionmark.circle.fill"
                tintColor = .systemGray
            }
            
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: status.description)?
                .withSymbolConfiguration(config)
            
            button.image = image
            button.image?.isTemplate = true
            
            if #available(macOS 11.0, *) {
                button.contentTintColor = tintColor
            }
        }
    }
    
    private func getOverallStatus() -> MoistureStatus {
        if sensors.isEmpty {
            return .unknown
        }
        
        let hasCritical = sensors.contains { $0.status == .critical }
        let hasNeedsAttention = sensors.contains { $0.status == .needsAttention }
        let hasUnknown = sensors.contains { $0.status == .unknown }
        
        if hasCritical {
            return .critical
        } else if hasNeedsAttention {
            return .needsAttention
        } else if hasUnknown {
            return .unknown
        } else {
            return .healthy
        }
    }
    
    @objc private func menuBarButtonClicked() {
        if !HubitatAPI.shared.isConfigured() {
            showPreferences()
            return
        }
        
        Task {
            await refreshData()
        }
    }
    
    private func updateMenu() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.menu.removeAllItems()
            
            if !HubitatAPI.shared.isConfigured() {
                let setupItem = NSMenuItem(title: "Setup Required", action: #selector(self.showPreferences), keyEquivalent: "")
                setupItem.target = self
                self.menu.addItem(setupItem)
                
                self.menu.addItem(NSMenuItem.separator())
                
                let quitItem = NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q")
                quitItem.target = self
                self.menu.addItem(quitItem)
                return
            }
            
            if self.isRefreshing {
                let refreshingItem = NSMenuItem(title: "Refreshing...", action: nil, keyEquivalent: "")
                refreshingItem.isEnabled = false
                self.menu.addItem(refreshingItem)
            } else {
                let refreshItem = NSMenuItem(title: "Refresh Now", action: #selector(self.refreshNow), keyEquivalent: "r")
                refreshItem.target = self
                self.menu.addItem(refreshItem)
            }
            
            self.menu.addItem(NSMenuItem.separator())
            
            if self.sensors.isEmpty {
                let noSensorsItem = NSMenuItem(title: "No moisture sensors found", action: nil, keyEquivalent: "")
                noSensorsItem.isEnabled = false
                self.menu.addItem(noSensorsItem)
            } else {
                for sensor in self.sensors {
                    let sensorItem = self.createSensorMenuItem(sensor: sensor)
                    self.menu.addItem(sensorItem)
                }
            }
            
            self.menu.addItem(NSMenuItem.separator())
            
            let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(self.showPreferences), keyEquivalent: ",")
            preferencesItem.target = self
            self.menu.addItem(preferencesItem)
            
            let quitItem = NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q")
            quitItem.target = self
            self.menu.addItem(quitItem)
        }
    }
    
    private func createSensorMenuItem(sensor: MoistureSensor) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = sensor.displayName
        item.target = self
        item.representedObject = sensor
        
        let submenu = NSMenu()
        
        let moistureItem = NSMenuItem(title: "Moisture: \(sensor.moisturePercentage)", action: nil, keyEquivalent: "")
        moistureItem.isEnabled = false
        submenu.addItem(moistureItem)
        
        if sensor.batteryLevel != nil {
            let batteryItem = NSMenuItem(title: "Battery: \(sensor.batteryPercentage)", action: nil, keyEquivalent: "")
            batteryItem.isEnabled = false
            submenu.addItem(batteryItem)
        }
        
        let statusItem = NSMenuItem(title: "Status: \(sensor.status.description)", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        submenu.addItem(statusItem)
        
        let lastActivityItem = NSMenuItem(title: "Last Update: \(sensor.lastActivityString)", action: nil, keyEquivalent: "")
        lastActivityItem.isEnabled = false
        submenu.addItem(lastActivityItem)
        
        submenu.addItem(NSMenuItem.separator())
        
        if sensor.status == .critical || sensor.status == .needsAttention {
            let justWateredItem = NSMenuItem(title: "Mark as Just Watered", action: #selector(markAsJustWatered(_:)), keyEquivalent: "")
            justWateredItem.target = self
            justWateredItem.representedObject = sensor
            submenu.addItem(justWateredItem)
        }
        
        if sensor.isJustWatered {
            let clearWateredItem = NSMenuItem(title: "Clear Watered Status", action: #selector(clearWateredStatus(_:)), keyEquivalent: "")
            clearWateredItem.target = self
            clearWateredItem.representedObject = sensor
            submenu.addItem(clearWateredItem)
        }
        
        item.submenu = submenu
        
        let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = NSImage(systemSymbolName: sensor.status.icon, accessibilityDescription: sensor.status.description)?
            .withSymbolConfiguration(config)
        item.image = image
        
        return item
    }
    
    @objc private func markAsJustWatered(_ sender: NSMenuItem) {
        guard let sensor = sender.representedObject as? MoistureSensor else { return }
        
        var settings = AppSettings.load()
        settings.justWateredSensors.insert(sensor.id)
        settings.justWateredTimestamps[sensor.id] = Date()
        settings.save()
        
        Task {
            await refreshData()
        }
    }
    
    @objc private func clearWateredStatus(_ sender: NSMenuItem) {
        guard let sensor = sender.representedObject as? MoistureSensor else { return }
        
        var settings = AppSettings.load()
        settings.justWateredSensors.remove(sensor.id)
        settings.justWateredTimestamps.removeValue(forKey: sensor.id)
        settings.save()
        
        Task {
            await refreshData()
        }
    }
    
    @objc private func refreshNow() {
        Task {
            await refreshData()
        }
    }
    
    @objc private func showPreferences() {
        if preferencesWindow == nil {
            let preferencesView = PreferencesView { [weak self] in
                self?.preferencesWindow?.close()
                self?.preferencesWindow = nil
                
                Task {
                    await self?.refreshData()
                }
            }
            
            let hostingController = NSHostingController(rootView: preferencesView)
            preferencesWindow = NSWindow(contentViewController: hostingController)
            preferencesWindow?.title = "Preferences"
            preferencesWindow?.styleMask = [.titled, .closable]
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.center()
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    private func startRefreshTimer() {
        let settings = AppSettings.load()
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: settings.refreshInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshData()
            }
        }
    }
    
    private func refreshData() async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        DispatchQueue.main.async { [weak self] in
            self?.updateMenu()
        }
        
        do {
            let fetchedSensors = try await HubitatAPI.shared.fetchMoistureSensors()
            
            DispatchQueue.main.async { [weak self] in
                self?.sensors = fetchedSensors
                self?.updateMenuBarIcon(status: self?.getOverallStatus() ?? .unknown)
                self?.isRefreshing = false
                self?.updateMenu()
            }
        } catch {
            print("Failed to refresh data: \(error)")
            
            DispatchQueue.main.async { [weak self] in
                self?.isRefreshing = false
                self?.updateMenuBarIcon(status: .unknown)
                self?.updateMenu()
                
                if let appError = error as? AppError {
                    self?.showErrorAlert(appError)
                }
            }
        }
    }
    
    private func showErrorAlert(_ error: AppError) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        
        if let appError = error as? AppError, appError == .authenticationError {
            alert.addButton(withTitle: "Preferences")
        }
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            showPreferences()
        }
    }
    
    func updateRefreshTimer() {
        startRefreshTimer()
    }
}

extension MenuBarController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if !isRefreshing && HubitatAPI.shared.isConfigured() {
            Task {
                await refreshData()
            }
        }
    }
}