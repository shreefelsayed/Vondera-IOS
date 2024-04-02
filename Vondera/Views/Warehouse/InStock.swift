//
//  InStock.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import SwiftUI

struct InStock: View {
    var storeId:String
    @ObservedObject var viewModel:InStockViewModel
    
    init(storeId: String) {
        self.storeId = storeId
        self.viewModel = InStockViewModel(storeId: storeId)
    }
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach($viewModel.items) { product in
                        WarehouseCard(prod: product)
                            .background(
                                NavigationLink("", destination: {
                                    ProductDetails(product: product, onDelete: { item in
                                        if let index = viewModel.items.firstIndex(where: {$0.id == item.id}) {
                                            viewModel.items.remove(at: index)
                                        }
                                    })
                                })
                            )
                        .buttonStyle(.plain)
                        
                        if viewModel.canLoadMore && viewModel.items.last?.id == product.id {
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
            }
            .scrollIndicators(.hidden)
            .refreshable {
                await refreshData()
            }
            .overlay {
                if viewModel.isLoading && viewModel.items.isEmpty {
                    ProgressView()
                } else if !viewModel.isLoading && viewModel.items.isEmpty {
                    EmptyMessageView(msg: "No items are in the warehouse")
                }
            }
            
            if !viewModel.items.isEmpty {
                FloatingActionButton(symbolName: "square.and.arrow.up.fill") {
                    if let url = WarehouseExcel(list: viewModel.items).generateReport() {
                        DispatchQueue.main.async {
                            FileUtils().shareFile(url: url)
                        }
                    }
                }
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

#Preview {
    InStock(storeId: Store.Qotoofs())
}
