//
//  ProductSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI

struct ProductSettings: View {
    var product:Product
    var storeId:String
    @State var delete = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            Section {
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
                
                Button("Delete Product") {
                    delete.toggle()
                }
                .foregroundColor(.red)
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
            do {
                try await ProductsDao(storeId:storeId).delete(id: product.id)
                
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ProductSettings_Previews: PreviewProvider {
    static var previews: some View {
        ProductSettings(product: Product.example(), storeId: "")
    }
}
