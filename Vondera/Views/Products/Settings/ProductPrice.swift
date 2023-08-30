//
//  ProductPrice.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductPrice: View {
    var product:Product
    @ObservedObject var viewModel:ProductPriceViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: Product) {
        self.product = product
        self.viewModel = ProductPriceViewModel(product: product)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Product Price", text: Binding(
                    get: { String(viewModel.price) },
                    set: { newValue in
                        viewModel.price = Int(newValue) ?? 0
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                
                Text("This is how much you sell the product for, please note that you can edit this on each order you make if you enable this option from store options.")
                    .font(.caption)
                
                TextField("Product Cost", text: Binding(
                    get: { String(viewModel.cost) },
                    set: { newValue in
                        viewModel.cost = Int(newValue) ?? 0
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                
                Text("This is how much your product costs you, so we can help you calculate your net profit.")
                    .font(.caption)
            }
            .isHidden(viewModel.isLoading)
        }
        .padding()
        .navigationTitle("Product Price")
        .overlay(alignment: .center, content: {
            ProgressView()
                .isHidden(!viewModel.isLoading)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(viewModel.isLoading)
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

struct ProductPrice_Previews: PreviewProvider {
    static var previews: some View {
        ProductPrice(product: Product.example())
    }
}
