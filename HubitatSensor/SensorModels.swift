import Foundation
import AppKit

struct HubitatDevice: Codable, Identifiable {
    let id: Int
    let name: String
    let label: String?
    let type: String
    let deviceNetworkId: String?
    
    var displayName: String {
        return label ?? name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as either string or int
        if let idString = try? container.decode(String.self, forKey: .id) {
            guard let idInt = Int(idString) else {
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Cannot convert id string to int")
            }
            self.id = idInt
        } else {
            self.id = try container.decode(Int.self, forKey: .id)
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.type = try container.decode(String.self, forKey: .type)
        self.deviceNetworkId = try container.decodeIfPresent(String.self, forKey: .deviceNetworkId)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, label, type, deviceNetworkId
    }
}

struct DeviceAttribute: Codable {
    let name: String
    let currentValue: String?
    let dataType: String?
    let unit: String?
}

struct MoistureSensor: Identifiable {
    let id: Int
    let name: String
    let customName: String?
    let moistureLevel: Double?
    let batteryLevel: Int?
    let lastActivity: Date?
    let status: MoistureStatus
    let isJustWatered: Bool
    
    var displayName: String {
        return customName ?? name
    }
    
    var moisturePercentage: String {
        guard let moisture = moistureLevel else { return "N/A" }
        return String(format: "%.0f%%", moisture)
    }
    
    var batteryPercentage: String {
        guard let battery = batteryLevel else { return "N/A" }
        return "\(battery)%"
    }
    
    var lastActivityString: String {
        guard let lastActivity = lastActivity else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastActivity, relativeTo: Date())
    }
}

enum MoistureStatus: CaseIterable {
    case healthy
    case needsAttention
    case critical
    case unknown
    case justWatered
    
    var color: NSColor {
        switch self {
        case .healthy, .justWatered:
            return .systemGreen
        case .needsAttention:
            return .systemYellow
        case .critical:
            return .systemRed
        case .unknown:
            return .systemGray
        }
    }
    
    var icon: String {
        switch self {
        case .healthy:
            return "leaf.fill"
        case .needsAttention:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "drop.fill"
        case .unknown:
            return "questionmark.circle.fill"
        case .justWatered:
            return "checkmark.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .healthy:
            return "Healthy"
        case .needsAttention:
            return "Needs Water"
        case .critical:
            return "Critical"
        case .unknown:
            return "Unknown"
        case .justWatered:
            return "Just Watered"
        }
    }
}

struct AppSettings {
    var hubIP: String = ""
    var apiToken: String = ""
    var refreshInterval: TimeInterval = 1800 // 30 minutes
    var healthyThreshold: Double = 40.0
    var criticalThreshold: Double = 20.0
    var customNames: [Int: String] = [:]
    var justWateredSensors: Set<Int> = []
    var justWateredTimestamps: [Int: Date] = [:]
    
    private static let userDefaults = UserDefaults.standard
    
    static func load() -> AppSettings {
        var settings = AppSettings()
        
        settings.hubIP = userDefaults.string(forKey: "hubIP") ?? ""
        settings.refreshInterval = userDefaults.double(forKey: "refreshInterval")
        if settings.refreshInterval == 0 {
            settings.refreshInterval = 1800
        }
        settings.healthyThreshold = userDefaults.double(forKey: "healthyThreshold")
        if settings.healthyThreshold == 0 {
            settings.healthyThreshold = 40.0
        }
        settings.criticalThreshold = userDefaults.double(forKey: "criticalThreshold")
        if settings.criticalThreshold == 0 {
            settings.criticalThreshold = 20.0
        }
        
        if let customNamesData = userDefaults.data(forKey: "customNames"),
           let customNames = try? JSONDecoder().decode([Int: String].self, from: customNamesData) {
            settings.customNames = customNames
        }
        
        if let justWateredData = userDefaults.data(forKey: "justWateredSensors"),
           let justWatered = try? JSONDecoder().decode(Set<Int>.self, from: justWateredData) {
            settings.justWateredSensors = justWatered
        }
        
        if let timestampsData = userDefaults.data(forKey: "justWateredTimestamps"),
           let timestamps = try? JSONDecoder().decode([Int: Date].self, from: timestampsData) {
            settings.justWateredTimestamps = timestamps
        }
        
        return settings
    }
    
    func save() {
        AppSettings.userDefaults.set(hubIP, forKey: "hubIP")
        AppSettings.userDefaults.set(refreshInterval, forKey: "refreshInterval")
        AppSettings.userDefaults.set(healthyThreshold, forKey: "healthyThreshold")
        AppSettings.userDefaults.set(criticalThreshold, forKey: "criticalThreshold")
        
        if let customNamesData = try? JSONEncoder().encode(customNames) {
            AppSettings.userDefaults.set(customNamesData, forKey: "customNames")
        }
        
        if let justWateredData = try? JSONEncoder().encode(justWateredSensors) {
            AppSettings.userDefaults.set(justWateredData, forKey: "justWateredSensors")
        }
        
        if let timestampsData = try? JSONEncoder().encode(justWateredTimestamps) {
            AppSettings.userDefaults.set(timestampsData, forKey: "justWateredTimestamps")
        }
    }
}

enum AppError: LocalizedError, Equatable {
    case networkError(String)
    case apiError(String)
    case authenticationError
    case invalidConfiguration
    case keychainError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .authenticationError:
            return "Authentication failed. Please check your API token."
        case .invalidConfiguration:
            return "Invalid configuration. Please check your settings."
        case .keychainError(let message):
            return "Keychain Error: \(message)"
        }
    }
}

