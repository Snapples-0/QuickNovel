//
//  HomeView.swift
//  QuickNovel
//
//  Home screen showing trending/popular novels
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("QuickNovel")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Discover and read novels from multiple sources")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Featured Section
                if viewModel.isLoading {
                    ForEach(0..<3) { _ in
                        ShimmerNovelCard()
                    }
                } else {
                    ForEach(viewModel.featuredNovels) { novel in
                        NavigationLink(destination: NovelDetailView(novelUrl: novel.url, provider: viewModel.selectedProvider)) {
                            NovelCard(novel: novel)
                        }
                    }
                }
                
                // Popular Novels
                SectionHeader(title: "Popular Novels")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ForEach(viewModel.popularNovels) { novel in
                            NavigationLink(destination: NovelDetailView(novelUrl: novel.url, provider: viewModel.selectedProvider)) {
                                CompactNovelCard(novel: novel)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Latest Updates
                SectionHeader(title: "Latest Updates")
                
                ForEach(viewModel.latestNovels) { novel in
                    NavigationLink(destination: NovelDetailView(novelUrl: novel.url, provider: viewModel.selectedProvider)) {
                        NovelListRow(novel: novel)
                    }
                }
            }
        }
        .navigationTitle("Home")
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadData()
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal)
            .padding(.top, 10)
    }
}

// MARK: - Novel Card
struct NovelCard: View {
    let novel: SearchResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: novel.posterUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(height: 200)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(novel.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                if let author = novel.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let rating = novel.rating {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", Double(rating) / 20.0))
                            .font(.subheadline)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}

// MARK: - Compact Novel Card
struct CompactNovelCard: View {
    let novel: SearchResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: novel.posterUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 120, height: 180)
            .cornerRadius(8)
            .clipped()
            
            Text(novel.name)
                .font(.caption)
                .lineLimit(2)
                .frame(width: 120)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Novel List Row
struct NovelListRow: View {
    let novel: SearchResponse
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: novel.posterUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 90)
            .cornerRadius(6)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(novel.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                if let author = novel.author {
                    Text(author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let latestChapter = novel.latestChapter {
                    Text(latestChapter)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Shimmer Loading Card
struct ShimmerNovelCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 16)
            }
            .padding()
        }
        .cornerRadius(12)
        .padding(.horizontal)
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}
