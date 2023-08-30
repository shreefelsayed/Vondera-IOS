//
//  StoreCouriers.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI
import AdvancedList

struct StoreCouriers: View {
    var storeId:String
    @StateObject var viewModel:StoreCouriersViewModel
    
    init(storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: StoreCouriersViewModel(storeId: storeId))
    }
    
    var body: some View {
        VStack {
            if !viewModel.couriers.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        SearchBar(text: $viewModel.searchText, hint: "Search \($viewModel.couriers.count) Couriers")
                        
                        ForEach(viewModel.filteredItems) { item in
                            NavigationLink(destination: CourierCurrentOrders(storeId: storeId, courier: item)) {
                                CourierCard(courier: item)
                            }
                            .buttonStyle(PlainButtonStyle())
                           
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Couriers 🛵")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Add", destination: NewCourier(storeId: storeId, currentList: $viewModel.couriers))
            }
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.couriers.isEmpty {
                EmptyMessageView(msg: "You haven't added any couriers yet")
            }
        }
        
    }
}

struct StoreCouriers_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StoreCouriers(storeId: Store.Qotoofs())
        }

    }
}
