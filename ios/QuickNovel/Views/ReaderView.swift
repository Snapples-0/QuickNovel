//
//  ReaderView.swift
//  QuickNovel
//
//  Main reading interface with customization options
//

import SwiftUI
import AVFoundation

struct ReaderView: View {
    let novelUrl: String
    let novelName: String
    let chapters: [ChapterData]
    
    @StateObject private var viewModel: ReaderViewModel
    @StateObject private var ttsManager = TTSManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingSettings = false
    @State private var showingChapterList = false
    @State private var currentChapterIndex = 0
    
    init(novelUrl: String, novelName: String, chapters: [ChapterData]) {
        self.novelUrl = novelUrl
        self.novelName = novelName
        self.chapters = chapters
        _viewModel = StateObject(wrappedValue: ReaderViewModel(chapters: chapters))
    }
    
    var body: some View {
        ZStack {
            Color(viewModel.settings.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Chapter title bar
                HStack {
                    Text(viewModel.currentChapter?.name ?? "Loading...")
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Menu {
                        Button(action: { showingSettings = true }) {
                            Label("Reading Settings", systemImage: "textformat.size")
                        }
                        Button(action: { showingChapterList = true }) {
                            Label("Chapter List", systemImage: "list.bullet")
                        }
                        Button(action: { ttsManager.toggleTTS() }) {
                            Label(ttsManager.isPlaying ? "Stop TTS" : "Start TTS", systemImage: ttsManager.isPlaying ? "stop.circle" : "play.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.95))
                
                // Reader content
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: viewModel.settings.lineSpacing * 10) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if let content = viewModel.chapterContent {
                                Text(viewModel.displayText)
                                    .font(.custom(viewModel.settings.fontName, size: viewModel.settings.fontSize))
                                    .foregroundColor(Color(hex: viewModel.settings.textColor))
                                    .multilineTextAlignment(textAlignment)
                                    .padding()
                                    .id("content")
                            }
                        }
                    }
                    .onAppear {
                        Task {
                            await viewModel.loadChapter(at: currentChapterIndex)
                            if ttsManager.isPlaying {
                                ttsManager.speak(text: viewModel.displayText)
                            }
                        }
                    }
                }
                
                // Navigation controls
                HStack {
                    Button(action: previousChapter) {
                        Label("Previous", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(currentChapterIndex == 0)
                    
                    Divider()
                    
                    Button(action: nextChapter) {
                        Label("Next", systemImage: "chevron.right")
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(currentChapterIndex >= chapters.count - 1)
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.95))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSettings) {
            ReadingSettingsView(settings: $viewModel.settings)
        }
        .sheet(isPresented: $showingChapterList) {
            ChapterListView(chapters: chapters, currentIndex: $currentChapterIndex) { index in
                currentChapterIndex = index
                Task {
                    await viewModel.loadChapter(at: index)
                }
            }
        }
        .onDisappear {
            ttsManager.stop()
        }
    }
    
    private var textAlignment: TextAlignment {
        switch viewModel.settings.textAlignment {
        case "center": return .center
        case "right": return .trailing
        default: return .leading
        }
    }
    
    private func previousChapter() {
        guard currentChapterIndex > 0 else { return }
        currentChapterIndex -= 1
        Task {
            await viewModel.loadChapter(at: currentChapterIndex)
            if ttsManager.isPlaying {
                ttsManager.speak(text: viewModel.displayText)
            }
        }
    }
    
    private func nextChapter() {
        guard currentChapterIndex < chapters.count - 1 else { return }
        currentChapterIndex += 1
        Task {
            await viewModel.loadChapter(at: currentChapterIndex)
            if ttsManager.isPlaying {
                ttsManager.speak(text: viewModel.displayText)
            }
        }
    }
}

// MARK: - Reading Settings View
struct ReadingSettingsView: View {
    @Binding var settings: ReadingSettings
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Text")) {
                    Stepper("Font Size: \(Int(settings.fontSize))", value: $settings.fontSize, in: 12...32)
                    
                    Picker("Font", selection: $settings.fontName) {
                        Text("System").tag("System")
                        Text("Georgia").tag("Georgia")
                        Text("Times New Roman").tag("Times New Roman")
                        Text("Courier").tag("Courier")
                    }
                    
                    Stepper("Line Spacing: \(String(format: "%.1f", settings.lineSpacing))", value: $settings.lineSpacing, in: 1.0...2.5, step: 0.1)
                    
                    Picker("Alignment", selection: $settings.textAlignment) {
                        Text("Left").tag("left")
                        Text("Center").tag("center")
                        Text("Right").tag("right")
                    }
                }
                
                Section(header: Text("Colors")) {
                    ColorPicker("Text Color", selection: Binding(
                        get: { Color(hex: settings.textColor) },
                        set: { settings.textColor = $0.toHex() }
                    ))
                    
                    ColorPicker("Background Color", selection: Binding(
                        get: { Color(hex: settings.backgroundColor) },
                        set: { settings.backgroundColor = $0.toHex() }
                    ))
                }
                
                Section(header: Text("Features")) {
                    Toggle("Bionic Reading", isOn: $settings.bionicReading)
                }
                
                Section(header: Text("Text-to-Speech")) {
                    Toggle("Enable TTS", isOn: $settings.ttsEnabled)
                    if settings.ttsEnabled {
                        Slider(value: $settings.ttsRate, in: 0.1...1.0) {
                            Text("Speech Rate: \(String(format: "%.1f", settings.ttsRate))")
                        }
                        Slider(value: $settings.ttsPitch, in: 0.5...2.0) {
                            Text("Pitch: \(String(format: "%.1f", settings.ttsPitch))")
                        }
                    }
                }
            }
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Chapter List View
struct ChapterListView: View {
    let chapters: [ChapterData]
    @Binding var currentIndex: Int
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(chapters.enumerated()), id: \.element.id) { index, chapter in
                    Button(action: {
                        onSelect(index)
                        dismiss()
                    }) {
                        HStack {
                            Text(chapter.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if index == currentIndex {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chapters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
