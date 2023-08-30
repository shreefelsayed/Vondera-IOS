//
//  CreateCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import LoadingButton

struct CreateCategory: View {
    var storeId:String
    @Binding var listCategories:[Category]
    @ObservedObject var viewModel:CreateCategoryViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, listCategories:Binding<[Category]>) {
        self.storeId = storeId
        self._listCategories = listCategories
        self.viewModel = CreateCategoryViewModel(storeId: storeId)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                HStack {
                    if viewModel.selectedImage != nil {
                        Image(uiImage: viewModel.selectedImage)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(alignment: .center) {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .opacity(0.4)
                            }.onTapGesture {
                                viewModel.pickPhotos()
                            }
                    } else {
                        Rectangle().foregroundColor(.gray)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(alignment: .center) {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .opacity(0.4)
                            }.onTapGesture {
                                viewModel.pickPhotos()
                            }
                    }
                    
                    
                    TextField("Category name", text: $viewModel.name)
                        .roundedTextFieldStyle()
                        .autocapitalization(.words)
                }
                
                
                
                LoadingButton(action: {
                    save()
                }, isLoading: $viewModel.isSaving, style: LoadingButtonStyle(width: .infinity, cornerRadius: 16, backgroundColor: .accentColor, loadingColor: .white)) {
                    Text("Create Category")
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding()
        .navigationTitle("New Category")
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                if viewModel.category != nil {
                    listCategories.append(viewModel.category!)
                }
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
        }
        .willProgress(saving: viewModel.isSaving)
    }
    
    func save() {
        Task {
            await viewModel.saveCategory()
        }
    }
}
