//
//  UserOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 21/06/2023.
//

import SwiftUI
import AdvancedList
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
            EmptyMessageView(msg: "You haven't added any orders yet !")
        }, errorStateView: { error in
            Text(error.localizedDescription).lineLimit(nil)
        }, loadingStateView: {
            ProgressView()
        }).pagination(.init(type: .thresholdItem(offset: 5), shouldLoadNextPage: {
            loadItem()
        }) {
        }).onAppear {
            loadItem()
        }.refreshable(action: {
            await refreshData()
        })
        .padding(.vertical)
        .navigationTitle("Your Orders 📦")
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

struct UserOrders_Previews: PreviewProvider {
    static var previews: some View {
        UserOrders(id: "", storeId: "")
    }
}

