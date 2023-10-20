//
//  InStock.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI

struct OutOfStock: View {
    var storeId:String
    
    @ObservedObject var viewModel:OutOfStockViewModel
    
    init(storeId: String) {
        self.storeId = storeId
        self.viewModel = OutOfStockViewModel(storeId: storeId)
    }
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            List {
                ForEach($viewModel.items) { item in
                    WarehouseCard(prod: item)
                    
                    if viewModel.canLoadMore && viewModel.items.last?.id == item.id {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .onAppear {
                            loadItem()
                        }
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            .listStyle(.plain)
            .overlay {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView()
                } else if !viewModel.isLoading && viewModel.items.isEmpty {
                    EmptyMessageView(msg: "No items are in the warehouse")
                }
            }
            
            FloatingActionButton(symbolName: "square.and.arrow.up.fill") {
                
                WarehouseExcel(list: viewModel.items)
                    .generateReport()
            }
        }
    }
    
    func loadItem() {
        Task {
            await viewModel.getData()
        }
    }
    
    func refreshData() async {
        await viewModel.refreshData()
    }
}

struct OutOfStock_Previews: PreviewProvider {
    static var previews: some View {
        OutOfStock(storeId: "")
    }
}
