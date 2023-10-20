//
//  ProductInfoView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductInfoView: View {
    var product:StoreProduct
    @ObservedObject var viewModel:ProductInfoViewModel
    var myUser = UserInformation.shared.user
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductInfoViewModel(product: product)
    }
    
    var body: some View {
        List {
            Section("Product info") {
                FloatingTextField(title: "Product Title", text: $viewModel.name, required: true, autoCapitalize: .words)
                
                FloatingTextField(title: "Description", text: $viewModel.desc, required: false, multiLine: true, autoCapitalize: .sentences)
            }
            
            Section("Category") {
                VStack (alignment: .leading) {
                    HStack {
                        Text(viewModel.category == nil ? "None was selected" : viewModel.category!.name)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                    }.onTapGesture {
                        viewModel.isSheetPresented = true
                    }
                    Text("Select the category that this product belongs too")
                        .font(.caption)
                }
                
            }

            Section("Stock Handling") {
                VStack(alignment: .leading) {
                    // MARK : Stock Options
                    Toggle(isOn: $viewModel.alwaysStocked) {
                        Text("Always in stock")
                    }
                    
                    Text("Turning this on will disable stock handling for this product")
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Product info")
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
        .sheet(isPresented: $viewModel.isSheetPresented) {
            CategoryPicker(items: $viewModel.categories, storeId: myUser?.storeId ?? "", selectedItem: $viewModel.category)
        }
    }
    
    func update() {
        Task {
            await viewModel.update()
        }
    }
}

#Preview {
    ProductInfoView(product: StoreProduct.example())
}
