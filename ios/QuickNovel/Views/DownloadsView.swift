//
//  DownloadsView.swift
//  QuickNovel
//

import SwiftUI

struct DownloadsView: View {
    @StateObject private var viewModel = DownloadsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("Downloads", selection: $selectedTab) {
                Text("Active").tag(0)
                Text("Completed").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            if selectedTab == 0 {
                ActiveDownloadsView(downloads: viewModel.activeDownloads)
            } else {
                CompletedDownloadsView(downloads: viewModel.completedDownloads)
            }
        }
        .navigationTitle("Downloads")
        .task {
            await viewModel.loadDownloads()
        }
    }
}

struct ActiveDownloadsView: View {
    let downloads: [DownloadProgress]
    
    var body: some View {
        if downloads.isEmpty {
            EmptyStateView(icon: "arrow.down.circle", message: "No active downloads")
        } else {
            List(downloads, id: \.novelUrl) { download in
                ActiveDownloadRow(download: download)
            }
        }
    }
}

struct ActiveDownloadRow: View {
    let download: DownloadProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(download.novelUrl.split(separator: "/").last.map(String.init) ?? "Unknown")
                    .font(.headline)
                Spacer()
                
                switch download.state {
                case .downloading:
                    Button(action: {}) {
                        Image(systemName: "pause.circle.fill")
                            .font(.title3)
                    }
                case .paused:
                    Button(action: {}) {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                    }
                default:
                    EmptyView()
                }
            }
            
            if case .downloading(let progress) = download.state {
                ProgressView(value: progress)
                Text("\(Int(progress * 100))% - Chapter \(download.currentChapter) of \(download.totalChapters)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if case .paused(let progress) = download.state {
                ProgressView(value: progress)
                Text("Paused at \(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CompletedDownloadsView: View {
    let downloads: [DownloadData]
    
    var body: some View {
        if downloads.isEmpty {
            EmptyStateView(icon: "checkmark.circle", message: "No completed downloads")
        } else {
            List(downloads) { download in
                NavigationLink(destination: ReaderView(novelUrl: download.url, novelName: download.novelName, chapters: [])) {
                    CompletedDownloadRow(download: download)
                }
            }
        }
    }
}

struct CompletedDownloadRow: View {
    let download: DownloadData
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: download.posterUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 90)
            .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(download.novelName)
                    .font(.headline)
                    .lineLimit(2)
                
                if let author = download.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(formatFileSize(download.fileSize))
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
