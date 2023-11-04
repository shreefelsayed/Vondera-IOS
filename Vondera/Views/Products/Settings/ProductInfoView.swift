//
//  ProductInfoView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast

class ProductNameVM : ObservableObject {
    @Published var product:StoreProduct
    @Published var categories = [Category]()
    @Published var selectedCategory:Category? {
        didSet {
            product.categoryId = selectedCategory?.id
            product.categoryName = selectedCategory?.name
        }
    }

    @Published var isLoading = true
    @Published var isSaving = false
    @Published var msg:String?

    init(product: StoreProduct) {
        self.product = product
        Task {
            await getData()
        }
    }
    
    func getData() async {
        self.isLoading = true
        if let category = try? await CategoryDao(storeId: product.storeId).getAll() {
            if let product = try? await ProductsDao(storeId: product.storeId).getProduct(id: product.id) {
                DispatchQueue.main.async {
                    self.product = product
                    self.categories = category
                    if let selectedIndex = self.categories.firstIndex(where: {$0.id == (product.categoryId ?? "")}) {
                        self.selectedCategory = self.categories[selectedIndex]
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    func update() async -> Bool {
        guard check() else {
            return false
        }
        
        
        
        self.isSaving = true
        // --> Update the database
        let data:[String:Any] = ["name": product.name,
                                 "desc": product.desc ?? "",
                                 "alwaysStocked": product.alwaysStocked ?? false,
                                 "categoryId": product.categoryId ?? "",
                                 "categoryName": product.categoryName ?? ""]
        
        if let _ = try? await ProductsDao(storeId: product.storeId).update(id: product.id, hashMap: data) {
            msg = "Store Main info changed"
            return true
        }
        
        return false
    }
    
    func check() -> Bool {
        guard !product.name.isBlank else {
            msg = "Fill the product name"
            return false
        }
        
        guard !(product.categoryId?.isBlank ?? true) else {
            msg = "Please select a cateogry"
            return false
        }
        
        return true
    }
}

struct ProductInfoView: View {
    @Binding var product:StoreProduct
    @ObservedObject var vm:ProductNameVM
    
    @State var isSheetPresented = false

    @Environment(\.presentationMode) private var presentationMode
    var myUser = UserInformation.shared.user

    init(product: Binding<StoreProduct>) {
        _product = product
        self.vm = ProductNameVM(product: product.wrappedValue)
    }
    
    var body: some View {
        List {
            Section("Product info") {
                FloatingTextField(title: "Product Title", text: $vm.product.name, required: true, autoCapitalize: .words)
                
                FloatingTextField(title: "Description", text: Binding(fromOptional: $vm.product.desc), required: false, multiLine: true, autoCapitalize: .sentences)
            }
            
            Section("Category") {
                VStack (alignment: .leading) {
                    HStack {
                        Text((vm.product.categoryId?.isBlank ?? true) ? "None was selected" : vm.product.categoryName ?? "")
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
                    Toggle(isOn: Binding(fromOptional: $vm.product.alwaysStocked, defaultValue: false)) {
                        Text("Always Stokced")
                    }
                    
                    Text("Turning this on will disable stock handling for this product")
                        .font(.caption)
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            NavigationStack {
                CategoryPicker(items: $vm.categories, storeId: myUser?.storeId ?? "", selectedItem: $vm.selectedCategory)
            }
        }
        .navigationBarBackButtonHidden(vm.isSaving)
        .navigationTitle("Product info")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(vm.isLoading || vm.isSaving)
            }
        }
        .willProgress(saving: vm.isSaving)
        .toast(isPresenting: Binding(value: $vm.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: vm.msg)
        }
        
    }
    
    func update() {
        Task {
            let success = await vm.update()
            if success {
                DispatchQueue.main.async {
                    self.product = vm.product
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
