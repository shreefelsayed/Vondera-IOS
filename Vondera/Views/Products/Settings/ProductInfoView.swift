//
//  ProductInfoView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI

struct ProductInfoView: View {
    @Binding var product:StoreProduct
    
    @State private var isSheetPresented = false

    @State private var name = ""
    @State private var desc = ""
    @State private var stocked = true
    
    @State private var categories = [Category]()
    @State private var selectedCategory:Category? = nil

    @State private var isLoading = true
    @State private var isSaving = false
    
    
    @Environment(\.presentationMode)  var presentationMode


    var body: some View {
        List {
            Section("Product info") {
                FloatingTextField(title: "Product Title", text: $name, required: true, autoCapitalize: .words)
                
                FloatingTextField(title: "Description", text: $desc, required: false, multiLine: true, autoCapitalize: .sentences)
            }
            
            Section("Category") {
                VStack (alignment: .leading) {
                    HStack {
                        Text(selectedCategory == nil ? "None was selected" : selectedCategory?.name ?? "")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }.onTapGesture {
                        isSheetPresented.toggle()
                    }
                    
                    Text("Select the category that this product belongs too")
                        .font(.caption)
                }
            }

            Section("Stock Handling") {
                VStack(alignment: .leading) {
                    // MARK : Stock Options
                    Toggle(isOn: $stocked) {
                        Text("Always Stokced")
                    }
                    
                    Text("Turning this on will disable stock handling for this product")
                        .font(.caption)
                }
            }
        }
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .sheet(isPresented: $isSheetPresented) {
            if let storeId = UserInformation.shared.user?.storeId {
                NavigationStack {
                    CategoryPicker(items: $categories, storeId: storeId, selectedItem: $selectedCategory)
                }
            }
        }
        .onChange(of: selectedCategory) { newValue in
            if let value = newValue {
                product.categoryId = value.id
                product.categoryName = value.name
            }
        }
        .navigationBarBackButtonHidden(isSaving)
        .navigationTitle("Product info")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    Task {
                        await update()
                    }
                }
                .disabled(isLoading || isSaving)
            }
        }
        .task {
            await getData()
        }
        
    }

    
    func getData() async {
        self.isLoading = true
        do {
            let category = try await CategoryDao(storeId: product.storeId).getAll()
            let product = try await ProductsDao(storeId: product.storeId).getProduct(id: product.id)
            
            guard let product = product else {
                return
            }
            
            DispatchQueue.main.async {
                self.product = product
                self.categories = category
                self.name = product.name
                self.desc = product.desc ?? ""
                self.stocked = product.alwaysStocked ?? false
                
                if let selectedIndex = self.categories.firstIndex(where: {$0.id == (product.categoryId ?? "")}) {
                    self.selectedCategory = self.categories[selectedIndex]
                }
                self.isLoading = false
            }
        } catch {
            print(error)
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    func update() async {
        guard let storeId = UserInformation.shared.user?.storeId, check() else {
            return
        }
        
        self.isSaving = true
        
        // --> Update the database
        let data:[String:Any] = ["name": name,
                                 "desc": desc,
                                 "alwaysStocked": stocked,
                                 "categoryId": selectedCategory?.id ?? "",
                                 "categoryName": selectedCategory?.name ?? ""]
        
        do {
            try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: data)
            
            DispatchQueue.main.async {
                self.product.name = name
                self.product.desc = desc
                self.product.alwaysStocked = stocked
                self.product.categoryId = selectedCategory?.id ?? ""
                self.product.categoryName = selectedCategory?.name ?? ""
                ToastManager.shared.showToast(msg: "Product info updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
            
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
        
        self.isSaving = false
    }
    
    func check() -> Bool {
        guard !product.name.isBlank else {
            ToastManager.shared.showToast(msg: "Fill the product name", toastType: .error)
            return false
        }
        
        guard !(product.categoryId?.isBlank ?? true) else {
            ToastManager.shared.showToast(msg: "Please select a cateogry", toastType: .error)
            return false
        }
        
        return true
    }
}
