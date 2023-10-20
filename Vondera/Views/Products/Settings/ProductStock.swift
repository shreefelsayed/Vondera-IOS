//
//  ProductStock.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductStock: View {
    var product:StoreProduct
    @ObservedObject var viewModel:ProductStocksViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductStocksViewModel(product: product)
    }
    
    var body: some View {
        List {
            FloatingTextField(title: "Amount to add", text: .constant(""), caption: "Enter how many pieces you want to add to your stock", required: true, isNumric: true, number: $viewModel.stock)
        }
        .isHidden(viewModel.isLoading)
        .navigationTitle("Product Stocks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    update()
                }
                .disabled(viewModel.isSaving || viewModel.isLoading)
            }
        }
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
        }
    }
    
    func update() {
        Task {
            await viewModel.update()
        }
    }
}

#Preview {
    ProductStock(product: StoreProduct.example())
}
