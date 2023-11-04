//
//  ConfirmedOrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI

struct ConfirmedOrdersFragment: View {
    @ObservedObject var viewModel = ConfirmedViewModel()
    @State var selectOrders = false
    
    var body: some View {
        List {
            SearchBar(text: $viewModel.searchText, hint: "Search \($viewModel.items.count) Orders")
            
            ForEach($viewModel.items.indices, id: \.self) { index in
                if $viewModel.items[index].wrappedValue.filter(searchText: viewModel.searchText) {
                    OrderCard(order: $viewModel.items[index]) {
                        selectOrders.toggle()
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.getData()
        }
        .overlay(alignment: .center) {
            if viewModel.items.isEmpty {
                EmptyMessageView(msg: "No Confirmed orders found")
            }
        }
        .sheet(isPresented: $selectOrders) {
            NavigationStack {
                OrderSelectView(list: $viewModel.items)
            }
        }
    }
}

struct ConfirmedOrdersFragment_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedOrdersFragment()
    }
}
