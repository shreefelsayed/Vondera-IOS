//
//  CourierFinishedOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import AdvancedList

struct CourierFinishedOrders: View {
    var courier:Courier
    
    @StateObject var viewModel:CourierFinishedViewModel
    
    init(courier: Courier) {
        self.courier = courier
        _viewModel = StateObject(wrappedValue: CourierFinishedViewModel(courier: courier))
    }
    
    var body: some View {
        AdvancedList(viewModel.items, listView: { rows in
            if #available(iOS 14, macOS 11, *) {
                ScrollView {
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
                EmptyMessageView(msg: "No orders were delivered by this courier")
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
        .navigationTitle("Finished Orders ✅")
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

struct CourierFinishedOrders_Previews: PreviewProvider {
    static var previews: some View {
        CourierFinishedOrders(courier: Courier.example())
    }
}
