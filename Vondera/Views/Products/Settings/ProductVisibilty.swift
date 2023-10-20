//
//  ProductVisibilty.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductVisibilty: View {
    var product:StoreProduct
    @ObservedObject var viewModel:ProductVisibiltyViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductVisibiltyViewModel(product: product)
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Toggle("Product Visibility", isOn: $viewModel.toogle)
                
                Text("Turning this off will hide this product and no one can make an order with it")
                    .font(.caption)
            }
        }
        .navigationTitle("Product Visibility")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
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
        .toast(isPresenting: Binding(value: $viewModel.msg)){
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
    ProductVisibilty(product: StoreProduct.example())
}
