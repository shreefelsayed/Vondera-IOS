//
//  ProductInfoView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductInfoView: View {
    var product:Product
    @ObservedObject var viewModel:ProductInfoViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: Product) {
        self.product = product
        self.viewModel = ProductInfoViewModel(product: product)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                
                TextField("Product Name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                
                // MARK : Select the Category
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.title2)
                    
                    HStack {
                        Text(viewModel.category == nil ? "None was selected" : viewModel.category!.name)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                    }
                }
                .onTapGesture {
                    viewModel.isSheetPresented = true
                }
                
                Text("Select the category that this product belongs too")
                    .font(.caption)
                
                TextField("Description (Optional)", text: $viewModel.desc, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)
                
                // MARK : Stock Options
                Toggle(isOn: $viewModel.alwaysStocked) {
                    Text("Always in stock")
                }
                
                Text("Turning this on will disable stock handling for this product")
                    .font(.caption)
               
            }
            .isHidden(viewModel.isLoading)
        }
        .padding()
        .navigationTitle("Product info")
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
        .sheet(isPresented: $viewModel.isSheetPresented) {
            CategoryPicker(items: viewModel.categories, selectedItem: $viewModel.category)
        }
    }
    
    func update() {
        Task {
            await viewModel.update()
        }
    }
}

struct ProductInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProductInfoView(product: Product.example())
    }
}
