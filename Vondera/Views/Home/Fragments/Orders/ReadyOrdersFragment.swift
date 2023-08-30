//
//  ReadyOrdersFragment.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import SwiftUI

struct ReadyOrdersFragment: View {
    @ObservedObject var viewModel = ReadyViewModel()

    var body: some View {
        ScrollView {
            PullToRefreshOld(coordinateSpaceName: "scrollView") {
                Task {
                    await viewModel.getOrdersList()
                }
            }
            
            VStack(spacing: 12) {
                HStack {
                    
                    SearchBar(text: $viewModel.searchText, hint: "Search \($viewModel.items.count) Orders")
                    
                
                    
                    NavigationLink(destination: OrderSelectView(list: $viewModel.items)) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.accentColor)
                    }
                    
                }
                
                ForEach(viewModel.filteredItems) {order in
                    OrderCard(order: order)
                }
            }.isHidden(viewModel.items.isEmpty)
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.items.isEmpty {
                EmptyMessageView(msg: "No ready orders found")
            }
        }
        .coordinateSpace(name: "scrollView")
    }
}

struct ReadyOrdersFragment_Previews: PreviewProvider {
    static var previews: some View {
        ReadyOrdersFragment()
    }
}
