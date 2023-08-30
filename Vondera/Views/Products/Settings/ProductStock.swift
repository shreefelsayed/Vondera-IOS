//
//  ProductStock.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductStock: View {
    var product:Product
    @ObservedObject var viewModel:ProductStocksViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: Product) {
        self.product = product
        self.viewModel = ProductStocksViewModel(product: product)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Amount to add", text: Binding(
                    get: { String(viewModel.stock) },
                    set: { newValue in
                        viewModel.stock = Int(newValue) ?? 0
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                
                Text("Enter how many pieces you want to add to your stock")
                    .font(.caption)
            }
        }
        .padding()
        .navigationTitle("Product Stocks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    update()
                }
                .disabled(viewModel.isSaving)
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

struct ProductStock_Previews: PreviewProvider {
    static var previews: some View {
        ProductStock(product: Product.example())
    }
}
