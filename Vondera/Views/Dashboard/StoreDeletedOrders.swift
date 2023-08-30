//
//  StoreDeletedOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import SwiftUI
import AdvancedList

struct StoreDeletedOrders: View {
    var storeId:String
    @StateObject var viewModel:StoreDeletedOrdersViewModel
    
    init( storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: StoreDeletedOrdersViewModel(storeId: storeId))
    }
    
    var body: some View {
        AdvancedList(viewModel.items, listView: { rows in
            if #available(iOS 14, macOS 11, *) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, content: rows)
                        .padding()
                }
            } else {
                List(content: rows)
            }
        }, content: { item in
            OrderCard(order: item)
        }, emptyStateView: {
            if viewModel.isLoading == false {
                EmptyMessageView(msg: "No deleted orders found")
            }
        }, errorStateView: { error in
            Text(error.localizedDescription).lineLimit(nil)
        }, loadingStateView: {
            ProgressView()
        }).pagination(.init(type: .thresholdItem(offset: 5), shouldLoadNextPage: {
            loadItem()
        }) {
            if viewModel.isLoading {
                ProgressView()
            }
        }).onAppear {
            loadItem()
        }.refreshable(action: {
            await refreshData()
        })
        .padding(.vertical)
        .navigationTitle("Deleted Orders")
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

struct StoreDeletedOrders_Previews: PreviewProvider {
    static var previews: some View {
        StoreDeletedOrders(storeId: "")
    }
}
