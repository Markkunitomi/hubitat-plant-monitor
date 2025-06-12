import SwiftUI

struct PreferencesView: View {
    @State private var hubIP: String = ""
    @State private var apiToken: String = ""
    @State private var refreshInterval: Double = 30
    @State private var healthyThreshold: Double = 40
    @State private var criticalThreshold: Double = 20
    @State private var isTestingConnection = false
    @State private var connectionTestResult: String = ""
    @State private var showingConnectionResult = false
    @State private var sensors: [MoistureSensor] = []
    @State private var customNames: [Int: String] = [:]
    
    let onSave: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hubitat Configuration")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hub IP Address:")
                    TextField("192.168.1.100", text: $hubIP)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .help("Enter your Hubitat hub's IP address")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Maker API Token:")
                    SecureField("Enter API token", text: $apiToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .help("Enter your Maker API access token")
                }
                
                HStack {
                    Button("Test Connection") {
                        testConnection()
                    }
                    .disabled(hubIP.isEmpty || apiToken.isEmpty || isTestingConnection)
                    
                    if isTestingConnection {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Spacer()
                }
                
                if showingConnectionResult {
                    Text(connectionTestResult)
                        .foregroundColor(connectionTestResult.contains("Success") ? .green : .red)
                        .font(.caption)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Refresh Settings")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Refresh Interval: \(Int(refreshInterval)) minutes")
                    Slider(value: $refreshInterval, in: 5...120, step: 5)
                        .help("How often to check sensor data")
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Moisture Thresholds")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Healthy Threshold: \(Int(healthyThreshold))%")
                    Text("Below this level, plants need attention")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Slider(value: $healthyThreshold, in: 10...80, step: 5)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Critical Threshold: \(Int(criticalThreshold))%")
                    Text("Below this level, plants are in critical condition")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Slider(value: $criticalThreshold, in: 5...50, step: 5)
                }
            }
            
            if !sensors.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom Plant Names")
                        .font(.headline)
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(sensors, id: \.id) { sensor in
                                HStack {
                                    Text(sensor.name)
                                        .frame(width: 120, alignment: .leading)
                                    
                                    TextField("Custom name", text: Binding(
                                        get: { customNames[sensor.id] ?? "" },
                                        set: { customNames[sensor.id] = $0.isEmpty ? nil : $0 }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
            }
            
            Divider()
            
            HStack {
                Button("Cancel") {
                    onSave()
                }
                
                Spacer()
                
                Button("Save") {
                    saveSettings()
                    onSave()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            loadSettings()
        }
    }
    
    private func loadSettings() {
        let settings = AppSettings.load()
        hubIP = settings.hubIP
        refreshInterval = settings.refreshInterval / 60.0 // Convert to minutes
        healthyThreshold = settings.healthyThreshold
        criticalThreshold = settings.criticalThreshold
        customNames = settings.customNames
        
        do {
            apiToken = try KeychainHelper.shared.loadAPIToken()
        } catch {
            apiToken = ""
        }
        
        if !hubIP.isEmpty && !apiToken.isEmpty {
            loadSensors()
        }
    }
    
    private func saveSettings() {
        var settings = AppSettings.load()
        settings.hubIP = hubIP
        settings.refreshInterval = refreshInterval * 60.0 // Convert to seconds
        settings.healthyThreshold = healthyThreshold
        settings.criticalThreshold = criticalThreshold
        settings.customNames = customNames
        settings.save()
        
        do {
            try KeychainHelper.shared.saveAPIToken(apiToken)
        } catch {
            print("Failed to save API token: \(error)")
        }
        
        HubitatAPI.shared.updateCredentials(hubIP: hubIP, apiToken: apiToken)
    }
    
    private func testConnection() {
        isTestingConnection = true
        showingConnectionResult = false
        
        HubitatAPI.shared.updateCredentials(hubIP: hubIP, apiToken: apiToken)
        
        Task {
            do {
                let success = try await HubitatAPI.shared.testConnection()
                
                await MainActor.run {
                    isTestingConnection = false
                    connectionTestResult = success ? "Success! Connection established." : "Failed to connect."
                    showingConnectionResult = true
                    
                    if success {
                        loadSensors()
                    }
                }
            } catch {
                await MainActor.run {
                    isTestingConnection = false
                    connectionTestResult = "Error: \(error.localizedDescription)"
                    showingConnectionResult = true
                }
            }
        }
    }
    
    private func loadSensors() {
        Task {
            do {
                let fetchedSensors = try await HubitatAPI.shared.fetchMoistureSensors()
                
                await MainActor.run {
                    sensors = fetchedSensors
                }
            } catch {
                print("Failed to load sensors: \(error)")
            }
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(onSave: {})
    }
}