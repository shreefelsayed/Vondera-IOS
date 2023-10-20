//
//  UserOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI
import SkeletonUI

struct UserOrders: View {
    var id:String
    var storeId:String
    @StateObject var viewModel:UserOrdersViewModel
    
    init(id: String, storeId: String) {
        self.id = id
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: UserOrdersViewModel(id: id, storeId: storeId))
    }
    
    var body: some View {
        List {
            
            ForEach($viewModel.items) { order in
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
        .refreshable {
            await refreshData()
        }
        .listStyle(.plain)
        .overlay {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "You haven't added any orders yet !")
            }
        }
        .navigationTitle("Your Orders 📦")
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

struct UserOrders_Previews: PreviewProvider {
    static var previews: some View {
        UserOrders(id: "", storeId: "")
    }
}

