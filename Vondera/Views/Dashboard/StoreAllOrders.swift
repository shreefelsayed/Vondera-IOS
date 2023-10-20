//
//  StoreAllOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI

struct StoreAllOrders: View {
    var storeId:String
    @StateObject var viewModel:StoreAllOrdersViewModel
    
    init( storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: StoreAllOrdersViewModel(storeId: storeId))
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
                EmptyMessageView(msg: "No orders were added to your store")
            }
        }
        .navigationTitle("All Store Orders 📦")
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

struct StoreAllOrders_Previews: PreviewProvider {
    static var previews: some View {
        StoreAllOrders(storeId: "")
    }
}
