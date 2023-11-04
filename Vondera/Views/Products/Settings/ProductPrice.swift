//
//  ProductPrice.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductPrice: View {
    var product:StoreProduct
    @ObservedObject var viewModel:ProductPriceViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductPriceViewModel(product: product)
    }
    
    var body: some View {
        List {
            Section {
                FloatingTextField(title: "Product Price", text: .constant(""), caption: "This is the selling price of the product which the user will be charged at", required: true, isNumric: true, number: $viewModel.price)
                
                FloatingTextField(title: "Crossed Price", text: .constant(""), caption: "This is showed in your website, to compare the price this doesn't have any effect on the real price", required: false, isNumric: true, number: $viewModel.crossed)
                
                FloatingTextField(title: "Product Cost", text: .constant(""), caption: "This how much the product costs you", required: true, isNumric: true, number: $viewModel.cost)
            }
            
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Margin")
                            .bold()
                        
                        Text(viewModel.cost == 0 ? "100%" : "\((viewModel.price / viewModel.cost) * 100)%")
                    }
                    .padding(24)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Profit")
                            .bold()
                        
                        Text("EGP \(viewModel.price - viewModel.cost)")
                    }
                    .padding(24)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
        .listStyle(.plain)
        .isHidden(viewModel.isLoading)
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .navigationTitle("Product Price")
        .overlay(alignment: .center) {
            ProgressView()
                .isHidden(!viewModel.isLoading)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(viewModel.isLoading || viewModel.isSaving)
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
    ProductPrice(product: StoreProduct.example())
}
