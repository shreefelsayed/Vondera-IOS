//
//  CourierCurrentOrders.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct CourierCurrentOrders: View {
    var courier:Courier
    var storeId:String
    @State var myUser:UserData?
    @State var selectOrders = false
    @StateObject var viewModel:CourierCurrentOrdersViewModel
    

    
    init(storeId: String, courier:Courier) {
        self.storeId = storeId
        self.courier = courier
        _viewModel = StateObject(wrappedValue: CourierCurrentOrdersViewModel(storeId: storeId, courierId: courier.id))
    }
    
    var body: some View {
        List {
            ForEach($viewModel.items.indices, id: \.self) { index in
                if $viewModel.items[index].wrappedValue.filter(searchText: viewModel.searchText) {
                    OrderCard(order: $viewModel.items[index], allowSelect: {
                        selectOrders.toggle()
                    })
                }
            }
           
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: "Search \($viewModel.items.count) Orders")
        .overlay(alignment: .center) {
            if !viewModel.isLoading && viewModel.items.isEmpty {
                EmptyMessageView(msg: "The courier has no ongoing orders")
            }
        }
        .refreshable {
            await viewModel.getCourierOrders()
        }
        .task {
            myUser = UserInformation.shared.getUser()
        }
        .navigationTitle("Courier Orders 🛵")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if myUser != nil && myUser!.canAccessAdmin {
                    NavigationLink("Settings") {
                        CourierSettingsView(courier: courier, storeId: storeId)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $selectOrders) {
            OrderSelectView(list: $viewModel.items)
        }
        
    }
}

struct CourierCurrentOrders_Previews: PreviewProvider {
    static var previews: some View {
        CourierCurrentOrders(storeId: "", courier: Courier.example())
    }
}
