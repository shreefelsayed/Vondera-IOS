//
//  StoresScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2024.
//

import SwiftUI
import FirebaseFirestore

class StopedSubscribeStoresVM : ObservableObject {
    @Published var isLoading = false
    @Published var isFetching = false
    
    var lastDoc:DocumentSnapshot? = nil
    var hasMore = true
    var items = [Store]()
    
    
    init() {
        Task {
            await fetch()
        }
    }
    
    func fetch() async {
        guard hasMore, !isLoading, !isFetching else { return }
        
        isLoading = lastDoc == nil
        isFetching = lastDoc != nil
        
        do {
            let result = try await StoresDao().getStopedSubscribing(lastSnapshot: lastDoc)
            DispatchQueue.main.async {
                self.hasMore = !result.0.isEmpty
                self.items.append(contentsOf: result.0)
                self.lastDoc = result.1
                self.isLoading = false
                self.isFetching = false
            }
        } catch {
            print(error)
        }
    }
}

struct StopedSubscribeStores: View {
    @StateObject private var viewModel = StopedSubscribeStoresVM()
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.ownerId) { store in
                VStack {
                    NavigationLink {
                        StoresProfileScreen(id: store.ownerId)
                    } label: {
                        StoreCard(store: store)
                    }
                    .buttonStyle(.plain)

                    if store.ownerId == viewModel.items.last?.ownerId && viewModel.hasMore {
                        ProgressView()
                            .onAppear {
                                Task { await viewModel.fetch() }
                            }
                    }
                }
                
            }
        }
        .willLoad(loading: viewModel.isLoading)
        .navigationTitle("Stoped Subscribing")
    }
}
