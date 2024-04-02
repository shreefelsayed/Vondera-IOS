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
        VStack(alignment: .leading) {
            if !viewModel.items.isEmpty {
                SearchBar(text: $viewModel.searchText, hint: "Search \($viewModel.items.count) Orders")
                    .padding(.horizontal)
            }
            
            List {
                ForEach($viewModel.items.indices, id: \.self) { index in
                    if $viewModel.items[index].wrappedValue.filter(searchText: viewModel.searchText) {
                        OrderCard(order: $viewModel.items[index]) {
                            selectOrders.toggle()
                        }
                        .listRowBackground(Color.clear)

                    }
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .padding()
            .overlay(alignment: .center) {
                if viewModel.items.isEmpty {
                    EmptyMessageView(msg: "No new orders found")
                }
            }
            .refreshable {
                await viewModel.getData()
            }
        }
        .sheet(isPresented: $selectOrders) {
            NavigationStack {
                OrderSelectView(list: $viewModel.items)
            }
        }
        
    }
    
    func print() {
        Task {
            if !viewModel.items.isEmpty, let uri = await ReciptPDF(orderList: viewModel.items).render() {
                DispatchQueue.main.async {
                    FileUtils().shareFile(url: uri)
                }
            }
        }
    }
}

#Preview {
    LatestOrdersFragment()
}
