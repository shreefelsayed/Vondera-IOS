//
//  ProductSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI

struct ProductSettings: View {
    @State var product : StoreProduct
    var onDeleted:((StoreProduct)->())

    @State private var delete = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            NavigationLink("Product info") {
                ProductInfoView(product:product)
            }
            
            NavigationLink("Variants") {
                ProductVarients(product:product)
            }
            
            NavigationLink("Price and cost") {
                ProductPrice(product:product)
            }
            
            NavigationLink("Product photos") {
                ProductPhotos(product:product)
            }
            
            if !(product.alwaysStocked ?? false) {
                NavigationLink("Add to stock") {
                    ProductStock(product:product)
                }
            }

            NavigationLink("Product Visibility") {
                ProductVisibilty(product:product)
            }
            
            Button("Delete Product", role:.destructive) {
                delete.toggle()
            }
        }
        .refreshable {
            await refresh()
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
            do {
                try await ProductsDao(storeId:product.storeId).delete(id: product.id)
                DispatchQueue.main.async {
                    onDeleted(product)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func refresh() async {
        do {
            if let product = try await ProductsDao(storeId: product.storeId).getProduct(id: product.id) {
                DispatchQueue.main.async {
                    self.product = product
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
