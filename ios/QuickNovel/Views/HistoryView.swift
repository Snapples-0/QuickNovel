//
//  HistoryView.swift
//  QuickNovel
//

import SwiftUI

@available(iOS 16.0, *)
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        Group {
            if viewModel.history.isEmpty {
                EmptyStateView(icon: "clock", message: "No reading history yet")
            } else {
                List {
                    ForEach(viewModel.history) { entry in
                        NavigationLink(destination: NovelDetailView(novelUrl: entry.url, provider: nil)) {
                            HistoryRow(entry: entry)
                        }
                    }
                    .onDelete(perform: viewModel.deleteHistory)
                }
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !viewModel.history.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        viewModel.clearAllHistory()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .task {
            await viewModel.loadHistory()
        }
    }
}

struct HistoryRow: View {
    let entry: HistoryEntry
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: entry.posterUrl ?? "")) { image in
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
                Text(entry.novelName)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(entry.lastChapterName)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .lineLimit(1)
                
                if let total = entry.totalChapters {
                    Text("Progress: \(entry.readingPosition)/\(total) chapters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(formatDate(entry.lastAccessDate))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
