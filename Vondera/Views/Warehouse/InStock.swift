//
//  InStock.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI
import AdvancedList

struct InStock: View {
    var storeId:String
    @ObservedObject var viewModel:InStockViewModel
    
    init(storeId: String) {
        self.storeId = storeId
        print("View inited")
        self.viewModel = InStockViewModel(storeId: storeId)
    }
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            AdvancedList(viewModel.items, listView: { rows in
                if #available(iOS 14, macOS 11, *) {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, content: rows)
                            .padding()
                    }
                } else {
                    List(content: rows)
                }
            }, content: { item in
                WarehouseCard(prod: item)
            }, listState: viewModel.state, emptyStateView: {
                EmptyMessageView(msg: "No items are in the warehouse")
            }, errorStateView: { error in
                Text(error.localizedDescription).lineLimit(nil)
            }, loadingStateView: {
                ProgressView()
            }).pagination(.init(type: .lastItem, shouldLoadNextPage: {
                loadItem()
            }) {
            })
            
            FloatingActionButton(symbolName: "square.and.arrow.up.fill") {
                
                WarehouseExcel(list: viewModel.items)
                    .generateReport()
            }
        }
        
    }
    
    func loadItem() {
        if !viewModel.canLoadMore { return }
        Task {
            await viewModel.getData()
        }
    }
}

struct InStock_Previews: PreviewProvider {
    static var previews: some View {
        InStock(storeId: "")
    }
}
