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
    @State var resetDialog = false
    @ObservedObject var viewModel:ProductStocksViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductStocksViewModel(product: product)
    }
    
    var body: some View {
        List {
            FloatingTextField(title: "Amount to add", text: .constant(""), caption: "Enter how many pieces you want to add to your stock", required: true, isNumric: true, number: $viewModel.stock, enableNegative: true)
            
            
            Text("You can add negative numbers to decrease your current warehouse items")
                .font(.caption)
        }
        .isHidden(viewModel.isLoading)
        .navigationTitle("Product Stocks")
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset", role: .destructive) {
                    resetDialog.toggle()
                }
                .disabled(viewModel.isSaving || viewModel.isLoading)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    update()
                }
                .disabled(viewModel.isSaving || viewModel.isLoading)
            }
        }
        .willProgress(saving: viewModel.isSaving)
        .confirmationDialog("Reset warehouse count", isPresented: $resetDialog, actions: {
            Button("Reset", role: .destructive) {
                Task {
                    await viewModel.reset()
                }
            }
            
            Button("Cancel", role: .cancel) {
            }
        }, message: {
            Text("This will set your product as out of stock, and the avilable quantity to zero")
        })
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
