//
//  OrderSearchView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI

struct OrderSearchView: View {
    var storeId:String
    
    @StateObject var viewModel:OrderSearchViewModel
    
    init(storeId:String) {
        self.storeId = storeId
        _viewModel = StateObject(wrappedValue:OrderSearchViewModel(storeId:storeId))
    }
    
    var body: some View {
        List {
            ForEach($viewModel.result) { order in
                OrderCard(order: order)
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText, prompt: "Search by name, phone or id")
        .overlay(alignment: .center, content: {
            if viewModel.result.isEmpty {
                EmptyMessageView(msg: "No result is avilable for \(viewModel.searchText)")
            }
        })
        .navigationTitle("Search for order")
    }
}

struct OrderSearchView_Previews: PreviewProvider {
    static var previews: some View {
        OrderSearchView(storeId: "")
    }
}
