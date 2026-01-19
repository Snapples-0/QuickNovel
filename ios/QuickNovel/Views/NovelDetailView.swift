//
//  NovelDetailView.swift
//  QuickNovel
//
//  Novel details page with chapters, synopsis, and download options
//

import SwiftUI

struct NovelDetailView: View {
    let novelUrl: String
    let provider: String?
    
    @StateObject private var viewModel: NovelDetailViewModel
    @State private var showingDownloadOptions = false
    @State private var isBookmarked = false
    
    init(novelUrl: String, provider: String?) {
        self.novelUrl = novelUrl
        self.provider = provider
        _viewModel = StateObject(wrappedValue: NovelDetailViewModel(novelUrl: novelUrl, providerName: provider))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let novel = viewModel.novel {
                    // Header with poster and info
                    HStack(alignment: .top, spacing: 16) {
                        AsyncImage(url: URL(string: novel.posterUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(novel.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(3)
                            
                            if let author = novel.author {
                                Label(author, systemImage: "person.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let rating = novel.rating {
                                HStack {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < rating ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                    Text(String(format: "%.1f", Double(rating)))
                                        .font(.caption)
                                }
                            }
                            
                            Text("\(viewModel.chapters.count) Chapters")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            if let firstChapter = viewModel.chapters.first {
                                // Navigate to reader
                            }
                        }) {
                            Label("Read", systemImage: "book.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showingDownloadOptions = true
                        }) {
                            Label("Download", systemImage: "arrow.down.circle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isBookmarked.toggle()
                        }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .frame(width: 50, height: 50)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tags
                    if let tags = novel.tags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(15)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Synopsis
                    if let synopsis = novel.synopsis {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Synopsis")
                                .font(.headline)
                            Text(synopsis)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    // Chapters
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Chapters")
                                .font(.headline)
                            Spacer()
                            Menu {
                                Button("Sort: Ascending") { viewModel.sortChapters(ascending: true) }
                                Button("Sort: Descending") { viewModel.sortChapters(ascending: false) }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down.circle")
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.chapters) { chapter in
                                NavigationLink(destination: ReaderView(novelUrl: novelUrl, novelName: novel.name, chapters: viewModel.chapters)) {
                                    ChapterRow(chapter: chapter)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadNovelDetails()
        }
        .sheet(isPresented: $showingDownloadOptions) {
            DownloadOptionsView(novel: viewModel.novel, chapters: viewModel.chapters)
        }
    }
}

// MARK: - Chapter Row
struct ChapterRow: View {
    let chapter: ChapterData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                if let date = chapter.dateOfRelease {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Download Options View
struct DownloadOptionsView: View {
    let novel: StreamResponse?
    let chapters: [ChapterData]
    @Environment(\.dismiss) var dismiss
    @State private var selectedChapters = Set<UUID>()
    @State private var downloadAll = true
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Download All Chapters", isOn: $downloadAll)
                    .padding()
                
                if !downloadAll {
                    List(chapters) { chapter in
                        Button(action: {
                            if selectedChapters.contains(chapter.id) {
                                selectedChapters.remove(chapter.id)
                            } else {
                                selectedChapters.insert(chapter.id)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedChapters.contains(chapter.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedChapters.contains(chapter.id) ? .blue : .gray)
                                Text(chapter.name)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                Button(action: {
                    // Start download
                    dismiss()
                }) {
                    Text("Start Download")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Download Chapters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
