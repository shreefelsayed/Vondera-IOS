//
//  ClientsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import AdvancedList

struct ClientsView: View {
    var store:Store
    @StateObject var viewModel:ClientsViewModel
    
    init(store:Store) {
        self.store = store
        _viewModel = StateObject(wrappedValue:ClientsViewModel(storeId: store.ownerId))
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchText)
                .padding(.horizontal)

            AdvancedList(viewModel.filteredItems, listView: { rows in
                
                if #available(iOS 14, macOS 11, *) {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, content: rows)
                            .padding()
                    }
                } else {
                    List(content: rows)
                }
            }, content: { item in
                NavigationLink {
                    ClientOrders(client: item, storeId: store.ownerId)
                } label: {
                    ClientCard(client: item)
                }.buttonStyle(PlainButtonStyle())

                
            }, listState: viewModel.state, emptyStateView: {
                EmptyMessageView(msg: "No one shopped from your store yet :(")
            }, errorStateView: { error in
                Text(error.localizedDescription).lineLimit(nil)
            }, loadingStateView: {
                ProgressView()
            }).pagination(.init(type: .thresholdItem(offset: 5), shouldLoadNextPage: {
                loadItem()
            }) {
            }).refreshable(action: {
                await refreshData()
            })
            
            Spacer()
        }
        
        .navigationTitle("Shoppers")
        .navigationBarTitleDisplayMode(.large)
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

struct ClientsView_Previews: PreviewProvider {
    static var previews: some View {
        ClientsView(store: Store.example())
    }
}
