//
//  ProductVisibilty.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductVisibilty: View {
    var product:Product
    @ObservedObject var viewModel:ProductVisibiltyViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: Product) {
        self.product = product
        self.viewModel = ProductVisibiltyViewModel(product: product)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Product Visibility", isOn: $viewModel.toogle)
                
                Text("Turning this off will hide this product and no one can make an order with it")
                    .font(.caption)
            }
            .isHidden(viewModel.isLoading)
        }
        .padding()
        .navigationTitle("Product Visibility")
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

struct ProductVisibilty_Previews: PreviewProvider {
    static var previews: some View {
        ProductVisibilty(product: Product.example())
    }
}
