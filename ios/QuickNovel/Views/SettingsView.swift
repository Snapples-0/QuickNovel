//
//  SettingsView.swift
//  QuickNovel
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultProvider") private var defaultProvider = ""
    @AppStorage("downloadWifiOnly") private var downloadWifiOnly = true
    @AppStorage("autoDownloadChapters") private var autoDownloadChapters = false
    @AppStorage("cacheSize") private var cacheSize = 100.0
    
    var body: some View {
        Form {
            Section(header: Text("General")) {
                Picker("Default Provider", selection: $defaultProvider) {
                    Text("None").tag("")
                    ForEach(ProviderRegistry.shared.getAllProviders(), id: \.name) { provider in
                        Text(provider.name).tag(provider.name)
                    }
                }
            }
            
            Section(header: Text("Downloads")) {
                Toggle("Download on Wi-Fi Only", isOn: $downloadWifiOnly)
                Toggle("Auto-download Chapters", isOn: $autoDownloadChapters)
            }
            
            Section(header: Text("Storage")) {
                HStack {
                    Text("Cache Size")
                    Spacer()
                    Text("\(Int(cacheSize)) MB")
                        .foregroundColor(.secondary)
                }
                
                Button("Clear Cache") {
                    NetworkManager.shared.clearCache()
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("3.4.1")
                        .foregroundColor(.secondary)
                }
                
                Link("Source Code", destination: URL(string: "https://github.com/LagradOst/QuickNovel")!)
                Link("Discord", destination: URL(string: "https://discord.gg/5Hus6fM")!)
            }
            
            Section {
                Button("Reset All Settings") {
                    resetSettings()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
    }
    
    private func resetSettings() {
        defaultProvider = ""
        downloadWifiOnly = true
        autoDownloadChapters = false
        cacheSize = 100.0
    }
}
