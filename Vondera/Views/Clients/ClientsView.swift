//
//  ClientsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct ClientsView: View {
    var store:Store
    @StateObject var viewModel:ClientsViewModel
    
    init(store:Store) {
        self.store = store
        _viewModel = StateObject(wrappedValue:ClientsViewModel(storeId: store.ownerId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.filteredItems) { item in
                ClientCard(client: item, storeId: store.ownerId)
                
                if viewModel.canLoadMore && viewModel.items.last?.id == item.id {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .onAppear {
                        loadItem()
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search your shoppers by name")
        .listStyle(.plain)
        .refreshable {
            await refreshData()
        }
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "No one shopped from your store yet :(")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort Option", selection: $viewModel.sortIndex) {
                        Text("Name")
                            .tag("name")
                        
                        Text("Last Order")
                            .tag("lastOrder")
                        
                        Text("Orders Count")
                            .tag("ordersCount")
                        
                        Text("Total Spent")
                            .tag("total")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .navigationTitle("Shoppers")
    }
    
    func refreshData() async {
        await viewModel.refreshData()
    }
    
    func loadItem() {
        Task {
            await viewModel.getData()
        }
    }
}

#Preview {
    ClientsView(store: Store.example())
}

