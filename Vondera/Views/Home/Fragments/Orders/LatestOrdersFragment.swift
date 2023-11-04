//
//  LatestOrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI

struct LatestOrdersFragment: View {
    @ObservedObject var viewModel = LatestViewModel()
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
        .overlay(alignment: .center) {
            if viewModel.items.isEmpty {
                EmptyMessageView(msg: "No new orders found")
            }
        }
        .refreshable {
            await viewModel.getData()
        }
        
        .sheet(isPresented: $selectOrders) {
            NavigationStack {
                OrderSelectView(list: $viewModel.items)
            }
        }
    }
}

struct LatestOrdersFragment_Previews: PreviewProvider {
    static var previews: some View {
        LatestOrdersFragment()
    }
}
