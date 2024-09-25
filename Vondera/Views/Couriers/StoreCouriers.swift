//
//  StoreCouriers.swift
//  Vondera
//
//  Created by Shreif El Sayed on 22/06/2023.
//

import SwiftUI

struct StoreCouriers: View {
    @StateObject private var viewModel = StoreCouriersViewModel()
    @State private var showAdd = false
    var body: some View {
        List {
            SkeltonManager(isLoading: viewModel.isLoading, count: 6, skeltonView: CourierCardSkelton())
            
            Section {
                ForEach(viewModel.filteredItems) { item in
                    CourierCardWithNavigation(courier: item)
                }
            }            
        }
        .refreshable {
            await viewModel.getCouriers()
        }
        .searchable(text: $viewModel.searchText, prompt: "Search \($viewModel.couriers.count) Couriers")
        .withEmptyViewButton(image: .btnShipping, text: "You haven't added any couriers yet", buttonText: "Add Courier", count: viewModel.couriers.count, loading: viewModel.isLoading, onAction: {
            showAdd.toggle()
        })
        .withEmptySearchView(searchText: viewModel.searchText, resultCount: viewModel.filteredItems.count)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    /*NavigationLink {
                       BannedEmployees()
                    } label: {
                        Image(.btnBan)
                    }*/
                    
                    Button {
                        showAdd.toggle()
                    } label: {
                        Image(systemName: "plus.app")
                    }
                    
                }
                .buttonStyle(.plain)
                .font(.title2)
                .bold()
            }
        }
        .navigationDestination(isPresented: $showAdd, destination: {
            NewCourier(currentList: $viewModel.couriers)
        })
        .navigationTitle("Couriers")
    }
}
