//
//  StoreCouriers.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct StoreCouriers: View {
    var storeId:String
    @StateObject var viewModel:StoreCouriersViewModel
    
    init(storeId: String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue: StoreCouriersViewModel(storeId: storeId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.filteredItems) { item in
                CourierCardWithNavigation(courier: item)
            }
        }
        .refreshable {
            await viewModel.getCouriers()
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: "Search \($viewModel.couriers.count) Couriers")
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
                EmptyMessageView(systemName: "bicycle.circle", msg: "You haven't added any couriers yet")
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
