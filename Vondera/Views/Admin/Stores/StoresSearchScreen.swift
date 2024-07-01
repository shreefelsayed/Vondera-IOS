//
//  StoresSearchScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI

struct StoresSearchScreen: View {
    @State private var searchText:String = ""
    @State private var isLoading = false
    @State private var items = [Store]()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                SearchBar(text: $searchText)
                
                Image(systemName: "magnifyingglass.circle.fill")
                    .onTapGesture {
                        search()
                    }
            }
            
            
            ForEach(items, id: \.ownerId) { store in
                VStack {
                    NavigationLink {
                        StoresProfileScreen(id: store.ownerId)
                    } label: {
                        StoreCard(store: store)
                    }
                    .buttonStyle(.plain)
                    Divider()
                }
            }
            
            Spacer()
        }
        .padding()
        .overlay {
            if isLoading { ProgressView() }
        }
        .navigationTitle("Store Search")
    }
    
    private func search() {
        self.isLoading = true
        
        Task {
            do {
                let result = try await StoresDao().search(query: searchText.lowercased())
                DispatchQueue.main.async {
                    self.items = result
                    self.isLoading = false
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    StoresSearchScreen()
}
