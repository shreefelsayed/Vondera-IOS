//
//  StoreDeletedOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct StoreDeletedOrders: View {
    var storeId:String
    @StateObject var viewModel:StoreDeletedOrdersViewModel
    
    init( storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: StoreDeletedOrdersViewModel(storeId: storeId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.searchText.isBlank ? $viewModel.items : $viewModel.result) { order in
                OrderCard(order: order)
                
                if viewModel.canLoadMore && viewModel.items.last?.id == order.id {
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
        .searchable(text: $viewModel.searchText, prompt: "Search by name, phone or id")
        .refreshable {
            await refreshData()
        }
        .listStyle(.plain)
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "No orders were deleted")
            }
        }
        .navigationTitle("Deleted Orders")
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
