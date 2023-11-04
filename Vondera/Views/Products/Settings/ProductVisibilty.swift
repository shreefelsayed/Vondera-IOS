//
//  ProductVisibilty.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

struct ProductVisibilty: View {
    @State var product:StoreProduct
    @Environment(\.presentationMode) private var presentationMode
    
    
    @State private var toogle = true
    
    @State private var isSaving = false
    @State private var isLoading = false
    @State private var msg:String?

    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Toggle("Product Visibility", isOn: $toogle)
                
                Text("Turning this off will hide this product and no one can make an order with it")
                    .font(.caption)
            }
        }
        .isHidden(isLoading)
        .overlay {
            ProgressView()
                .isHidden(!isLoading)
        }
        .navigationTitle("Product Visibility")
        .navigationBarBackButtonHidden(isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    Task {
                        await update()
                    }
                }
                .disabled(isSaving)
            }
        }
        .task {
            await updateData()
            updateUI()
        }
        .willProgress(saving: isSaving)
        .toast(isPresenting: Binding(value: $msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: msg)
        }
    }
    
    func updateData() async {
        self.isLoading = true
        if let product = try? await ProductsDao(storeId: product.storeId).getProduct(id: product.id) {
            DispatchQueue.main.async {
                self.product = product
                self.isLoading = false
            }
        }
    }
    
    func updateUI() {
        toogle = product.visible ?? true
    }
    
    func update() async {
        isSaving = true
        
        // --> Update the database
        let map:[String:Any] = ["visible": toogle]
        try? await ProductsDao(storeId: product.storeId).update(id: product.id, hashMap: map)
        
        DispatchQueue.main.async {
            self.msg = "Store Name Changed"
            self.isSaving = false
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ProductVisibilty(product: StoreProduct.example())
}
