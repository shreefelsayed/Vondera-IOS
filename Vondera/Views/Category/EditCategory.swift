//
//  EditCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import SwiftUI
import AlertToast
import FirebaseStorage
import PhotosUI


struct EditCategory: View {
    var category:Category
    var storeId:String
    var onUpdated:((Category) -> ())
    var onDeleted:((Category) -> ())

    @Environment(\.presentationMode) private var presentationMode
    
    @State private var name:String = ""
    @State private var desc:String = ""
    @State private var link:String = ""
    @State private var hidden = false
    @State private var selectedImage:UIImage?
    @State private var picker:PhotosPickerItem?
    
    @State private var deleteDialog = false
    @State private var msg:LocalizedStringKey?
    @State private var isSaving = false
    
    var body: some View {
        List {
            Section("Category info") {
                FloatingTextField(title: "Category Name", text: $name, required: nil, autoCapitalize: .words)
                
                PhotosPicker(selection: $picker) {
                    HStack {
                        Text("Thumbnail")
                        Spacer()
                        ImagePickupHolder(currentImageURL: link, selectedImage: selectedImage, currentImagePlaceHolder: UIImage(named: "defaultCategory"), reduis: 25)
                    }
                }
                
                FloatingTextField(title: "Category Describtion", text: $desc, caption: "This will be visible in your website, make it from 10 to 50 words max", required: false, multiLine: true)
                
                
                Toggle("Hide this category from the website", isOn: $hidden)
            }
        }
        .navigationTitle("Edit Category")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if AccessFeature.categoriesDelete.canAccess() {
                    Text("Delete")
                        .foregroundColor(.red)
                        .bold()
                        .disabled(isSaving)
                        .onTapGesture {
                            promoteDelete()
                        }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Text("Update")
                    .foregroundColor(.accentColor)
                    .bold()
                    .disabled(name.isEmpty || isSaving)
                    .onTapGesture {
                        updateData()
                    }
            }
        }
        .onChange(of: picker) { _ in
            Task {
                if let data = try? await picker?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        return
                    }
                }
                
                print("Failed")
            }
        }
        .alert(isPresented: $deleteDialog) {
            Alert(
                title: Text("Delete Category"),
                message: Text("Are you sure you want to delete this category ? your products won't be deleted"),
                
                primaryButton: .destructive(
                    Text("Delete").foregroundColor(.red), action: {
                        delete()
                    }),
                secondaryButton: .cancel()
            )
        }
        .toast(isPresenting: Binding(value: $msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: msg?.toString())
        }
        .willProgress(saving: isSaving)
        .navigationBarBackButtonHidden(isSaving)
        .task {
            name = category.name
            link = category.url
            desc = category.desc ?? ""
            hidden = category.hidden ?? false
        }
        .withAccessLevel(accessKey: .categoriesUpdate, presentation: presentationMode)

    }
    
    private func delete() {
        Task {
            await deleteCategory()
        }
    }
    
    private func promoteDelete() {
        deleteDialog.toggle()
    }
    
    private func updateData() {
        self.isSaving = true
        if selectedImage == nil {
            setData()
        } else {
            uploadImage()
        }
    }
    
    private func setData() {
        Task {
            let data:[String:Any] = ["name": name, "url" : link, "desc": desc, "hidden": hidden]
            try! await CategoryDao(storeId: storeId).update(id: category.id, hash: data)
            
            DispatchQueue.main.async {
                var newCategory = category
                newCategory.name = name
                newCategory.url = link
                newCategory.desc = desc
                newCategory.hidden = hidden
                self.isSaving = false
                onUpdated(newCategory)
            }
        }
    }
    
    private func deleteCategory() async {
        self.isSaving = true
        try! await CategoryDao(storeId: storeId).delete(id: category.id)
        
        DispatchQueue.main.async {
            self.isSaving = false
            onDeleted(category)
        }
    }
    
    private func uploadImage() {
        FirebaseStorageUploader().oneImageUpload(image: selectedImage!, ref: "stores/\(storeId)/categories/\(category.id).jpeg") { url, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.isSaving = false
                }
            } else if let url = url {
                self.link = url.absoluteString
                self.setData()
            }
        }
    }
}

