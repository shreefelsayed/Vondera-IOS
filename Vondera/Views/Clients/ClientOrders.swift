//
//  ClientOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI

struct ClientOrders: View {
    var client:Client
    var storeId:String
    @StateObject var viewModel:ClientOrdersViewModel
    
    init(client:Client, storeId:String) {
        self.storeId = storeId
        self.client = client

        _viewModel = StateObject(wrappedValue:ClientOrdersViewModel(id:client.phone, storeId: storeId))
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items.indices, id: \.self) { index in
                if $viewModel.items[index].wrappedValue.filter(searchText: viewModel.searchText) {
                    OrderCard(order: $viewModel.items[index])
                }
            }
        }
        .refreshable {
            await refreshData()
        }
        .searchable(text: $viewModel.searchText)
        .listStyle(.plain)
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "This shopper doesn't has any orders")
            }
        }
        .navigationTitle(client.name)
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
    ClientOrders(client: Client.example(), storeId: Store.Qotoofs())
}
