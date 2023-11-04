//
//  CourierFinishedOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct CourierFinishedOrders: View {
    var courier:Courier
    
    @StateObject var viewModel:CourierFinishedViewModel
    
    init(courier: Courier) {
        self.courier = courier
        _viewModel = StateObject(wrappedValue: CourierFinishedViewModel(courier: courier))
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
                EmptyMessageView(msg: "No orders were delivered by this courier")
            }
        }
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
