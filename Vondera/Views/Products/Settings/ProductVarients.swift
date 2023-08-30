//
//  ProductVarients.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductVarients: View {
    var product:Product
    @ObservedObject var viewModel:ProductVarientsViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: Product) {
        self.product = product
        self.viewModel = ProductVarientsViewModel(product: product)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if !viewModel.isLoading {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Variants are used to create different versions of the same product. For example, if you have a t-shirt, you can create a variant for each size and color, just click next if you don\'t have any variants")
                        .font(.caption)
                    
                    ForEach(Array($viewModel.listTitles.indices), id: \.self) { i in
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Variant Title", text: $viewModel.listTitles[i])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Spacer().frame(height: 6)
                            
                            ChipView(chips: $viewModel.listOptions[i], placeholder: "Enter Variants", useSpaces: true)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Spacer().frame(height: 6)
                            
                            
                            HStack {
                                ButtonLarge(label: "Delete Varient", background: .gray) {
                                    viewModel.deleteVarient(i : i)
                                }
                            }
                            
                            Divider()
                        }
                    }
                    
                    ButtonLarge(label: "Add New Variant") {
                        viewModel.addVarient()
                    }
                    
                }
                .isHidden(viewModel.isLoading)
            }
        }
        .padding()
        .navigationTitle("Product Varients")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(viewModel.isLoading)
            }
        }
        .overlay(alignment: .center, content: {
            ProgressView()
                .isHidden(!viewModel.isLoading)
        })
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

struct ProductVarients_Previews: PreviewProvider {
    static var previews: some View {
        ProductVarients(product: Product.example())
    }
}
