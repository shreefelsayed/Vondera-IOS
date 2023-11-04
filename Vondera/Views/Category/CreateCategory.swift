//
//  CreateCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import LoadingButton
import PhotosUI

struct CreateCategory: View {
    var storeId:String
    var onAdded : ((Category) -> ())? = nil
    
    @State var picker:PhotosPickerItem?
    @ObservedObject var viewModel:CreateCategoryViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, onAdded : ((Category) -> ())?) {
        self.storeId = storeId
        self.onAdded = onAdded
        self.viewModel = CreateCategoryViewModel(storeId: storeId)
    }
    
    var body: some View {
        List {
            Section("Category info") {
                FloatingTextField(title: "Category Name", text: $viewModel.name, required: nil, autoCapitalize: .words)
                
                PhotosPicker(selection: $picker) {
                    HStack {
                        Text("Thumbnail")
                        Spacer()
                        
                        ImagePickupHolder(currentImageURL: "", selectedImage: viewModel.selectedImage, currentImagePlaceHolder: UIImage(named: "defaultCateogry"), reduis: 30)
                    }
                }
                
            
                
                FloatingTextField(title: "Category Describtion", text: $viewModel.desc, caption: "This will be visible in your website, make it from 10 to 50 words max", required: false, multiLine: true)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Create")
                    .bold()
                    .disabled(viewModel.isSaving)
                    .foregroundStyle(Color.accentColor )
                    .onTapGesture {
                        save()
                    }
            }
        }
        .onChange(of: picker, perform: { _ in
            Task {
                if let data = try? await picker?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        viewModel.selectedImage = uiImage
                        return
                    }
                }
            }
        })
        .navigationTitle("New Category")
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                if let newItem = viewModel.category  {
                    if onAdded != nil {
                        onAdded!(newItem)
                    }
                }
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .toast(isPresenting: Binding(value: $viewModel.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg?.toString())
        }
        .willProgress(saving: viewModel.isSaving)
    }
    
    func save() {
        Task {
            await viewModel.saveCategory()
        }
    }
}

