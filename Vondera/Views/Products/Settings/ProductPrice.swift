//
//  ProductPrice.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI

struct ProductPrice: View {
    @Binding var product:StoreProduct
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var price:Double = 0
    @State private var cost:Double = 0
    @State private var crossed:Double = 0

    @State private var isSaving = false
    @State private var isLoading = false
    
    var body: some View {
        List {
            Section {
                FloatingTextField(title: "Product Price", text: .constant(""), caption: "This is the selling price of the product which the user will be charged at", required: true, isNumric: true, number: $price)
                
                FloatingTextField(title: "Crossed Price", text: .constant(""), caption: "This is showed in your website, to compare the price this doesn't have any effect on the real price", required: false, isNumric: true, number: $crossed)
                
                FloatingTextField(title: "Product Cost", text: .constant(""), caption: "This how much the product costs you", required: true, isNumric: true, number: $cost)
            }
            
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Margin")
                            .bold()
                        
                        Text(cost == 0 ? "100%" : "\(((price / cost) * 100).toString())%")
                    }
                    .padding(24)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Profit")
                            .bold()
                        
                        Text("EGP \((price - cost).toString())")
                    }
                    .padding(24)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
        .listStyle(.plain)
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .navigationTitle("Product Price")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(isLoading || isSaving)
            }
        }
        .willProgress(saving: isSaving)
        .task {
            await getData()
        }
    }
    
    func update() {
        Task {
            await update()
        }
    }
    
    
    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            if let product = try await ProductsDao(storeId: storeId).getProduct(id: product.id) {
                DispatchQueue.main.async {
                    self.product = product
                    self.cost = product.buyingPrice
                    self.price = product.price
                    self.crossed = product.crossedPrice ?? 0
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    
    func check() -> Bool{
        guard price != 0 else {
            ToastManager.shared.showToast(msg: "Selling price can't be Zero", toastType: .error)
            return false
        }
        
        if crossed > 0 && crossed < price {
            ToastManager.shared.showToast(msg: "Crossed price can't be less than the selling price", toastType: .error)
            return false
        }
        
        return true
    }
    
    func update() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        guard check() else {
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:Any] = ["buyingPrice": cost, "price" : price, "crossedPrice" : crossed]
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: map)
            
            DispatchQueue.main.async {
                ToastManager.shared.showToast(msg: "Product cost and price changed", toastType: .success)
                self.product.price = price
                self.product.buyingPrice = cost
                self.product.crossedPrice = crossed
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
}

