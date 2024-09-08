//
//  ProductVisibilty.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI

struct ProductFeatured: View {
    @State var product:StoreProduct
    @Environment(\.presentationMode) private var presentationMode
    
    
    @State private var toogle = true
    
    @State private var isSaving = false
    @State private var isLoading = false

    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Toggle("Featured Product", isOn: $toogle)
                
                Text("Turning this on will mark the product as featured on your website")
                    .font(.caption)
            }
        }
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .navigationTitle("Featured")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    Task {
                        await update()
                    }
                }
                .disabled(isSaving || isLoading)
            }
        }
        .task {
            await getData()
        }
    }
    
    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        
        do {
            let product = try await ProductsDao(storeId: storeId).getProduct(id: product.id)
            if let product = product {
                DispatchQueue.main.async {
                    self.product = product
                    self.toogle = product.featured ?? false
                    self.isLoading = false
                }
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }

    func update() async {
        guard UserInformation.shared.user?.storeId != nil else { return }
        
        self.isSaving = true
        
        // --> Update the database
        let map:[String:Any] = ["featured": toogle]
        
        do {
            try await ProductsDao(storeId: product.storeId).update(id: product.id, hashMap: map)
            DispatchQueue.main.async {
                self.product.featured = toogle
                self.isSaving = false
                
                ToastManager.shared.showToast(msg: "Product Updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
        
        self.isSaving = false
    }
}
