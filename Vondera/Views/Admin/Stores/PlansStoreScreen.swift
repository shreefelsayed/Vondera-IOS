//
//  PlansStoreScreen.swift
//  Vondera
//
//  Created by Shreif El Sayed on 13/10/2024.
//

import SwiftUI
import FirebaseFirestore

class PlansStoreScreenViewModel : ObservableObject {
    var plans: [String]
    @Published var isLoading = false
    @Published var isFetching = false
    
    var lastDoc:DocumentSnapshot? = nil
    var hasMore = true
    var items = [Store]()
    
    
    init(plans: [String]) {
        self.plans = plans
        Task {
            await fetch()
        }
    }
    
    func fetch() async {
        guard hasMore, !isLoading, !isFetching else { return }
        
        isLoading = lastDoc == nil
        isFetching = lastDoc != nil
        
        do {
            let result = try await StoresDao().getPlansStore(plans: plans, lastSnapshot: lastDoc)
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

struct PlansStoreScreen: View {
    @StateObject private var viewModel:PlansStoreScreenViewModel
    var plans:[String]
    var title:LocalizedStringKey
    
    init(plans: [String], title: LocalizedStringKey) {
        self._viewModel = StateObject(wrappedValue: PlansStoreScreenViewModel(plans:plans))
        self.plans = plans
        self.title = title
    }
    
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
        .navigationTitle(title)
    }
}
