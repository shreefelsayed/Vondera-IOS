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
                    }
                }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .padding()
            .overlay(alignment: .center) {
                if viewModel.items.isEmpty {
                    EmptyMessageView(msg: "No ready orders found")
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

struct ReadyOrdersFragment_Previews: PreviewProvider {
    static var previews: some View {
        ReadyOrdersFragment()
    }
}
