//
//  ProductPrice.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import FirebaseFirestore

struct ProductPrice: View {
    @Binding var product:StoreProduct
    @State private var hasVariants = false
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var showWarning = false
    
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
                    if hasVariants {
                        showWarning.toggle()
                    } else {
                        update(withVariant: false)
                    }
                }
                .disabled(isLoading || isSaving)
            }
        }
        .willProgress(saving: isSaving)
        .task {
            fetchData()
        }
        .confirmationDialog("Update Variants", isPresented: $showWarning) {
            Button("Update Varaints") {
                update(withVariant: true)
            }
            
            Button("Just update price", role: .cancel) {
                update(withVariant: false)
            }
        } message: {
            Text("Do you want to update the variants prices too ?")
        }

    }
    
    
    func fetchData() {
        guard let storeId = UserInformation.shared.user?.storeId else {return}
        isLoading = true
        
        Task {
            do {
                if let product = try await ProductsDao(storeId: storeId).getProduct(id: product.id) {
                    DispatchQueue.main.async {
                        self.product = product
                        self.hasVariants = product.hasVariants()
                        
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
    }
    
    
    func validate() -> Bool{
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
    
    func update(withVariant:Bool = false) {
        guard let storeId = UserInformation.shared.user?.storeId, validate() else { return }
        isSaving = true
        
        Task {
            do {
                // --> Update the database
                var map:[String:Any] = ["buyingPrice": cost, "price" : price, "crossedPrice" : crossed]
                try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: map)
                
                
                if withVariant {
                    var variantsMap:[String:[VariantsDetails]] = ["variantsDetails" : modifiedVariants()]
                    let encoded: [String: Any] = try! Firestore.Encoder().encode(variantsMap)
                    try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: encoded)
                }
                
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(msg: "Product cost and price changed", toastType: .success)
                    self.product.price = price
                    self.product.buyingPrice = cost
                    self.product.crossedPrice = crossed
                    
                    if withVariant {
                        self.product.variantsDetails = modifiedVariants()
                    }
                    
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
    
    func modifiedVariants() -> [VariantsDetails] {
        return product.getVariant().map {
            var item = $0
            item.price = price
            item.cost = cost
            
            return item
        }
    }
}

