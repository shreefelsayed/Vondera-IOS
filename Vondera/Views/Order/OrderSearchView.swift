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
        ScrollView(showsIndicators: false) {
            LazyVStack {
                SearchBar(text: $viewModel.searchText, hint: "Search by order number, name, phone number ...")
                
                ForEach(viewModel.result) { order in
                    OrderCard(order: order)
                }
                
                Spacer()
            }
        }.overlay(alignment: .center, content: {
            if viewModel.result.isEmpty {
                EmptyMessageView(msg: "No result is avilable for your search")
            }
        })
        .navigationTitle("Search for order")
        .padding()
    }
}

struct OrderSearchView_Previews: PreviewProvider {
    static var previews: some View {
        OrderSearchView(storeId: "")
    }
}
