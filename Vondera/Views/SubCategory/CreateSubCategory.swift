//
//  CreateSubCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 09/11/2024.
//

import SwiftUI

struct CreateSubCategory: View {
    var storeId:String
    var category:Category
    var subCategory:SubCategory?
    var onFinished : ((SubCategory) -> ())? = nil
    
    @State private var name = ""
    @State private var isSaving = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            FloatingTextField(title: "Sub Category Name", text: $name, required: true, autoCapitalize: .words)
            
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text(subCategory != nil ? "Creaet" : "Update")
                    .bold()
                    .foregroundStyle(Color.accentColor )
                    .onTapGesture {
                        save()
                    }
            }
        }
        .willProgress(saving: isSaving)
        .navigationTitle(subCategory != nil ? "Edit Sub Category" : "New Sub Category")
        .task {
            name = subCategory?.name ?? ""
        }
    }
    
    func validate() -> Bool {
        guard !name.isBlank else {
            ToastManager.shared.showToast(msg: "Enter the sub category name", toastType: .error)
            return false
        }
        
        return true
    }
    
    func save() {
        guard validate() else { return }
        self.isSaving = true
        
        Task {
            if isEdit() {
                await update()
            } else {
                await create()
            }
        }
    }
    
    func create() async {
        do {
            let subCategory = SubCategory(name: name, id: "", categoryId: category.id, sortValue: 0)
            let newItem = try await SubStoreCategoryDao(storeId: storeId).addCategory(subCategory: subCategory)
            DispatchQueue.main.async {
                self.isSaving = false
                ToastManager.shared.showToast(msg: "Sub Category Created !", toastType: .success)
                if let onFinished = self.onFinished {
                    onFinished(newItem)
                }
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func update() async {
        do {
            guard var subCategory = subCategory else { return }
            let data:[String:Any] = ["name": name]
            try await SubStoreCategoryDao(storeId: storeId).update(id: subCategory.id, data: data)
            subCategory.name = name
            DispatchQueue.main.async {
                self.isSaving = false
                ToastManager.shared.showToast(msg: "Sub Category Updated !", toastType: .success)
                if let onFinished = self.onFinished {
                    onFinished(subCategory)
                }
                self.presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func isEdit() -> Bool {
        return subCategory != nil
    }
}
