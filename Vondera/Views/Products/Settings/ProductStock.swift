//
//  ProductStock.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import FirebaseFirestore

struct VarintStocks: View {
    @Binding var product:StoreProduct
    @State private var varientDetails = [VariantsDetails]()
    @State private var isLoading = false
    @State private var isSaving = false
    
    @State private var newStock:[String] = []
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !varientDetails.isEmpty {
                    ForEach(varientDetails.indices, id: \.self) { index in
                        let item = varientDetails[index]
                        
                        HStack {
                            CachedImageView(imageUrl: item.getPhoto(), scaleType: .centerCrop, placeHolder: UIImage(resource: .products))
                                .frame(width: 60, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor, lineWidth: 1.5)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(item.formatOptions())
                                    .bold()
                                    .padding(.bottom, 6)
                                
                                if let stocked = product.alwaysStocked {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Quantity")
                                        
                                        TextField("Quantity", text: $newStock[index])
                                            .textFieldStyle(.roundedBorder)
                                            .disabled(stocked)
                                    }
                                }
                                
                                
                            }
                            
                        }
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    }
                }
                
            }
        }
        .padding()
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .task {
            await getData()
        }
        .navigationTitle("Product Stocks")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        await save()
                    }
                }
            }
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
                    migrateOptions()
                    self.isLoading = false
                }
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    func migrateOptions() {
        self.isLoading = true
        self.varientDetails = product.getVariant()
        
        for item in varientDetails {
            newStock.append("\(item.quantity)")
        }
        
        self.isLoading = false
    }
    
    
    func getList() -> [VariantsDetails] {
        var items = [VariantsDetails]()
        for (index, item) in varientDetails.enumerated() {
            var newItem = VariantsDetails(options: item.options, quantity: newStock[index].toInt, sold:0, image: item.image, cost: item.cost, price: item.price)
            newItem.optimizedImage = item.optimizedImage
            items.append(newItem)
        }
        
        return items
    }
    
    func save() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        
        
        
        let items = getList()
        
        do {
            let quantity = (product.alwaysStocked ?? false) ? 0 : items.totalQuantity()
            let map:[String:[VariantsDetails]] = ["variantsDetails": items]
            let encoded: [String: Any] = try! Firestore.Encoder().encode(map)
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: encoded)
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: ["quantity": quantity])
            
            DispatchQueue.main.async {
                self.product.variantsDetails = items
                self.product.quantity = quantity
                self.isSaving = false
                ToastManager.shared.showToast(msg: "Variants updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            self.isSaving = false
        }
    }
}

struct ProductQuantityScreen : View {
    @Binding var product:StoreProduct
    var body: some View {
        if product.hasVariants() {
            VarintStocks(product: $product)
        } else {
            ProductStock(product: $product)
        }
    }
}

struct ProductStock: View {
    @Binding var product:StoreProduct
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var stock = 0.0
    
    @State private var isSaving = false
    @State private var isLoading = false
    @State private var resetDialog = false
    
    
    var body: some View {
        List {
            FloatingTextField(title: "Amount to add", text: .constant(""), caption: "Enter how many pieces you want to add to your stock", required: true, isNumric: true, number: $stock, enableNegative: true)
            
            
            Text("You can add negative numbers to decrease your current warehouse items")
                .font(.caption)
        }
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .navigationTitle("Product Stocks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset", role: .destructive) {
                    resetDialog.toggle()
                }
                .disabled(isSaving)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    Task {
                        await update()
                    }
                }
                .disabled(isSaving)
            }
        }
        .confirmationDialog("Reset warehouse count", isPresented: $resetDialog, actions: {
            Button("Reset", role: .destructive) {
                Task {
                    await reset()
                }
            }
            
            Button("Cancel", role: .cancel) {
            }
        }, message: {
            Text("This will set your product as out of stock, and the avilable quantity to zero")
        })
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
                    self.stock = stock
                    self.isLoading = false
                }
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    
    func reset() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        
        do {
            // --> Update the database
            try await ProductsDao(storeId: storeId).addToStock(id: product.id, q: Double(-(product.quantity)))
            DispatchQueue.main.async {
                self.stock = 0
                ToastManager.shared.showToast(msg: "Product marked as out of stock", toastType: .success)
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            
        }
        
        self.isSaving = false
    }
    
    func update() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        
        do {
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: ["quantity": stock])
            
            DispatchQueue.main.async {
                self.product.quantity = Int(stock)
                ToastManager.shared.showToast(msg: "Product Stock Updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
        
        
        self.isSaving = false
    }
    
}
