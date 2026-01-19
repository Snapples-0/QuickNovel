//
//  SearchView.swift
//  QuickNovel
//
//  Search interface with provider selector
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var showingProviderPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar and provider selector
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search novels...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            Task {
                                await viewModel.search(query: searchText)
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            viewModel.clearResults()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Provider selector
                Button(action: {
                    showingProviderPicker = true
                }) {
                    HStack {
                        Text("Provider:")
                            .foregroundColor(.secondary)
                        Text(viewModel.selectedProvider?.displayName ?? "All Providers")
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(20)
                }
            }
            .padding()
            
            Divider()
            
            // Results
            if viewModel.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Searching...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.results.isEmpty && !searchText.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No results found")
                        .font(.headline)
                    Text("Try a different search term or provider")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.results.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Search for novels")
                        .font(.headline)
                    Text("Use the search bar above to find novels")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 160), spacing: 16)
                    ], spacing: 16) {
                        ForEach(viewModel.results) { novel in
                            NavigationLink(destination: NovelDetailView(novelUrl: novel.url, provider: viewModel.selectedProvider?.name)) {
                                SearchResultCard(novel: novel)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Search")
        .sheet(isPresented: $showingProviderPicker) {
            ProviderPickerView(selectedProvider: $viewModel.selectedProvider)
        }
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
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
            .frame(height: 220)
            .clipped()
            .cornerRadius(8)
            
            Text(novel.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            if let rating = novel.rating {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", Double(rating) / 20.0))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Provider Picker
struct ProviderPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedProvider: ProviderInfo?
    
    let providers: [ProviderInfo]
    
    init(selectedProvider: Binding<ProviderInfo?>) {
        self._selectedProvider = selectedProvider
        
        // Get all registered providers
        let allProviders = ProviderRegistry.shared.getAllProviders()
        self.providers = allProviders.map { provider in
            ProviderInfo(
                name: provider.name,
                displayName: provider.name,
                baseUrl: provider.baseUrl,
                supportedFeatures: provider.supportedFeatures
            )
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        selectedProvider = nil
                        dismiss()
                    }) {
                        HStack {
                            Text("All Providers")
                            Spacer()
                            if selectedProvider == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section {
                    ForEach(providers) { provider in
                        Button(action: {
                            selectedProvider = provider
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(provider.displayName)
                                    Text(provider.baseUrl)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedProvider?.name == provider.name {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Provider")
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
