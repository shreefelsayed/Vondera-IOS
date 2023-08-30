//
//  CourierCurrentOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import AdvancedList

struct CourierCurrentOrders: View {
    var courier:Courier
    var storeId:String
    @State var myUser:UserData?
    @StateObject var viewModel:CourierCurrentOrdersViewModel
    
    
    init(storeId: String, courier:Courier) {
        self.storeId = storeId
        self.courier = courier
        _viewModel = StateObject(wrappedValue: CourierCurrentOrdersViewModel(storeId: storeId, courierId: courier.id))
    }
    
    var body: some View {
        ScrollView {
            PullToRefreshOld(coordinateSpaceName: "scrollView") {
                Task {
                    await viewModel.getCourierOrders()
                }
            }
            
            VStack(spacing: 12) {
                HStack {
                    SearchBar(text: $viewModel.searchText, hint: "Search \($viewModel.orders.count) Orders")
                    
                
                    
                    NavigationLink(destination: OrderSelectView(list: $viewModel.orders)) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.accentColor)
                    }
                    
                }
                
                ForEach(viewModel.filteredItems) {order in
                    OrderCard(order: order)
                }
            }.isHidden(viewModel.orders.isEmpty)
        }
        .coordinateSpace(name: "scrollView")
        .padding()
        .overlay(alignment: .center, content: {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.orders.isEmpty {
                EmptyMessageView(msg: "The courier has no ongoing orders")
            }
        })
        .navigationTitle("Courier Orders 🛵")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                if myUser != nil && myUser!.canAccessAdmin {
                    NavigationLink("Settings") {
                        CourierSettingsView(courier: courier, storeId: storeId)
                    }
                }
            }
        })
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                myUser = await LocalInfo().getLocalUser()
            }
        }
    }
    
    func loadItem() {
        Task {
            await viewModel.getCourierOrders()
        }
    }
}

struct CourierCurrentOrders_Previews: PreviewProvider {
    static var previews: some View {
        CourierCurrentOrders(storeId: "", courier: Courier.example())
    }
}
