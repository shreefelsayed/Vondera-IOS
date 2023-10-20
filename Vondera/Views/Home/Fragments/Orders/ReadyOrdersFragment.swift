//
//  ReadyOrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI

struct ReadyOrdersFragment: View {
    @ObservedObject var viewModel = ReadyViewModel()
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
                EmptyMessageView(msg: "No ready orders found")
            }
        }
        .navigationDestination(isPresented: $selectOrders) {
            OrderSelectView(list: $viewModel.items)
        }
    }
}

struct ReadyOrdersFragment_Previews: PreviewProvider {
    static var previews: some View {
        ReadyOrdersFragment()
    }
}
