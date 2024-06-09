//
//  ProductSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI

struct ProductSettings: View {
    @Binding var product : StoreProduct
    var onDeleted:((StoreProduct)->())

    @State private var delete = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            NavigationLink("Name and Collection") {
               ProductInfoView(product: $product)
            }
            
            NavigationLink("Variants") {
                ProductVarients(product:$product)
            }
            
            if(!product.getVariant().isEmpty) {
                NavigationLink("Variants Customizations") {
                    VarientsSettings(product: $product)
                }
            }
            
            
            NavigationLink("Price and cost") {
                ProductPrice(product:$product)
            }
            
            NavigationLink("Change photos") {
                ProductPhotos(product:$product)
            }
            
            if !(product.alwaysStocked ?? false) {
                NavigationLink("Add to stock") {
                    ProductQuantityScreen(product:$product)
                }
            }

            NavigationLink("Product Visibility") {
                ProductVisibilty(product:product)
            }
            
            NavigationLink("Featured") {
                ProductFeatured(product:product)
            }
            
            Button("Delete Product", role:.destructive) {
                delete.toggle()
            }
        }
        .confirmationDialog("Are you sure you want to delete this product ?", isPresented: $delete, titleVisibility: .visible, actions: {
            Button("Delete", role: .destructive) {
                deleteProduct()
            }
            
            Button("Later", role: .cancel) {
            }
        })
        
        .navigationTitle(product.name)
    }
    
    
    
    func deleteProduct() {
        Task {
            if let _ = try? await ProductsDao(storeId: product.storeId).delete(id: product.id) {
                DispatchQueue.main.async {
                    onDeleted(product)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
