//
//  ClientOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/06/2023.
//

import SwiftUI
import AdvancedList

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
            
        }, listState: viewModel.state, emptyStateView: {
            EmptyMessageView(msg: "This shopper doesn't has any orders")
        }, errorStateView: { error in
            Text(error.localizedDescription).lineLimit(nil)
        }, loadingStateView: {
            ProgressView()
        }).onAppear {
            loadItem()
        }.refreshable(action: {
            await refreshData()
        })
        .navigationTitle(client.name)
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

struct ClientOrders_Previews: PreviewProvider {
    static var previews: some View {
        ClientOrders(client: Client.example(), storeId: "")
    }
}
