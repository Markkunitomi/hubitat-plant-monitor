import Foundation

class HubitatAPI {
    static let shared = HubitatAPI()
    
    private var hubIP: String = ""
    private var apiToken: String = ""
    private let session = URLSession.shared
    
    private init() {
        loadCredentials()
    }
    
    private func loadCredentials() {
        let settings = AppSettings.load()
        hubIP = settings.hubIP
        
        do {
            apiToken = try KeychainHelper.shared.loadAPIToken()
        } catch {
            print("Failed to load API token: \(error)")
        }
    }
    
    func updateCredentials(hubIP: String, apiToken: String) {
        self.hubIP = hubIP
        self.apiToken = apiToken
        
        do {
            try KeychainHelper.shared.saveAPIToken(apiToken)
        } catch {
            print("Failed to save API token: \(error)")
        }
    }
    
    func isConfigured() -> Bool {
        return !hubIP.isEmpty && !apiToken.isEmpty
    }
    
    private func makeRequest(endpoint: String) -> URLRequest? {
        guard !hubIP.isEmpty, !apiToken.isEmpty else {
            return nil
        }
        
        let baseURL = hubIP.hasPrefix("http") ? hubIP : "http://\(hubIP)"
        guard let url = URL(string: "\(baseURL)/apps/api/242/\(endpoint)?access_token=\(apiToken)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        return request
    }
    
    func fetchDevices() async throws -> [HubitatDevice] {
        guard let request = makeRequest(endpoint: "devices") else {
            throw AppError.invalidConfiguration
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError("Invalid response")
            }
            
            switch httpResponse.statusCode {
            case 200:
                let devices = try JSONDecoder().decode([HubitatDevice].self, from: data)
                return devices
            case 401:
                throw AppError.authenticationError
            default:
                throw AppError.apiError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }
    }
    
    func fetchDeviceAttributes(deviceId: Int) async throws -> [DeviceAttribute] {
        guard let request = makeRequest(endpoint: "devices/\(deviceId)") else {
            throw AppError.invalidConfiguration
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError("Invalid response")
            }
            
            switch httpResponse.statusCode {
            case 200:
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let attributesArray = json?["attributes"] as? [[String: Any]] ?? []
                
                let attributes = attributesArray.compactMap { attributeDict -> DeviceAttribute? in
                    guard let name = attributeDict["name"] as? String else { return nil }
                    
                    // Handle currentValue as either string or number
                    let currentValue: String?
                    if let stringValue = attributeDict["currentValue"] as? String {
                        currentValue = stringValue
                    } else if let numberValue = attributeDict["currentValue"] as? NSNumber {
                        currentValue = numberValue.stringValue
                    } else {
                        currentValue = nil
                    }
                    
                    let dataType = attributeDict["dataType"] as? String
                    let unit = attributeDict["unit"] as? String
                    
                    return DeviceAttribute(
                        name: name,
                        currentValue: currentValue,
                        dataType: dataType,
                        unit: unit
                    )
                }
                
                return attributes
            case 401:
                throw AppError.authenticationError
            default:
                throw AppError.apiError("HTTP \(httpResponse.statusCode)")
            }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error.localizedDescription)
        }
    }
    
    func fetchMoistureSensors() async throws -> [MoistureSensor] {
        let devices = try await fetchDevices()
        let moistureDevices = devices.filter { device in
            device.type.lowercased().contains("moisture") ||
            device.name.lowercased().contains("moisture") ||
            device.displayName.lowercased().contains("moisture") ||
            device.type.lowercased().contains("soil")
        }
        
        let settings = AppSettings.load()
        var sensors: [MoistureSensor] = []
        
        for device in moistureDevices {
            do {
                let attributes = try await fetchDeviceAttributes(deviceId: device.id)
                
                let moistureAttribute = attributes.first { attr in
                    let name = attr.name.lowercased()
                    return name.contains("moisture") || name == "humidity"
                }
                let batteryAttribute = attributes.first { $0.name.lowercased() == "battery" }
                
                let moistureLevel: Double?
                if let moistureString = moistureAttribute?.currentValue {
                    moistureLevel = Double(moistureString)
                } else {
                    moistureLevel = nil
                }
                
                let batteryLevel: Int?
                if let batteryString = batteryAttribute?.currentValue {
                    batteryLevel = Int(batteryString)
                } else {
                    batteryLevel = nil
                }
                
                let lastActivity = Date()
                
                let status = determineStatus(
                    moistureLevel: moistureLevel,
                    deviceId: device.id,
                    settings: settings
                )
                
                let sensor = MoistureSensor(
                    id: device.id,
                    name: device.displayName,
                    customName: settings.customNames[device.id],
                    moistureLevel: moistureLevel,
                    batteryLevel: batteryLevel,
                    lastActivity: lastActivity,
                    status: status,
                    isJustWatered: settings.justWateredSensors.contains(device.id)
                )
                
                sensors.append(sensor)
            } catch {
                print("Failed to fetch attributes for device \(device.id): \(error)")
                
                let sensor = MoistureSensor(
                    id: device.id,
                    name: device.displayName,
                    customName: settings.customNames[device.id],
                    moistureLevel: nil,
                    batteryLevel: nil,
                    lastActivity: nil,
                    status: .unknown,
                    isJustWatered: settings.justWateredSensors.contains(device.id)
                )
                
                sensors.append(sensor)
            }
        }
        
        return sensors
    }
    
    private func determineStatus(moistureLevel: Double?, deviceId: Int, settings: AppSettings) -> MoistureStatus {
        if settings.justWateredSensors.contains(deviceId) {
            if let timestamp = settings.justWateredTimestamps[deviceId],
               Date().timeIntervalSince(timestamp) < 24 * 60 * 60 {
                return .justWatered
            }
        }
        
        guard let moisture = moistureLevel else {
            return .unknown
        }
        
        if moisture <= settings.criticalThreshold {
            return .critical
        } else if moisture <= settings.healthyThreshold {
            return .needsAttention
        } else {
            return .healthy
        }
    }
    
    func testConnection() async throws -> Bool {
        _ = try await fetchDevices()
        return true
    }
}