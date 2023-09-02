//
//  EditCategory.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import SwiftUI
import AlertToast
import FirebaseStorage
import NetworkImage

struct ImagePlaceHolder: View {
    @Binding var url:String
    @Binding var image:UIImage?
    
    var onClick:(() -> ())
    var width:CGFloat = 60
    var height:CGFloat = 60
    var iconOverly = true
    
    var body: some View {
        ZStack {
            if image == nil {
                NetworkImage(url: URL(string: url ?? "")) { image in
                  image.centerCropped()
                } placeholder: {
                  ProgressView()
                }
                .background(Color.gray)
                .frame(width: width, height: height)
                .clipShape(Circle())
                .overlay(alignment: .center) {
                    if iconOverly {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .resizable()
                            .frame(width: CGFloat(width / 2), height: CGFloat(height / 2))
                            .opacity(0.4)
                    }
                    
                }.onTapGesture {
                    onClick()
                }
            } else {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
                    .overlay(alignment: .center) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .opacity(0.4)
                    }.onTapGesture {
                        onClick()
                    }
            }
        }
    }
}


struct EditCategory: View {
    
    var category:Category
    var storeId:String
    
    @ObservedObject var viewModel:EditCategoryViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, category:Category) {
        self.storeId = storeId
        self.category = category
        self.viewModel = EditCategoryViewModel(storeId: storeId, category:category)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                HStack {
                    ImagePlaceHolder(url: $viewModel.link, image: $viewModel.selectedImage, onClick: {
                        viewModel.pickPhotos()
                        print("Should pick")
                    }, iconOverly: true)
                    
                    
                    TextField("Category name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                }
            }
            
        }
        .padding()
        .navigationTitle("Edit Category")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Delete")
                    .foregroundColor(.red)
                    .bold()
                    .disabled(viewModel.isSaving)
                    .onTapGesture {
                        promoteDelete()
                    }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Text("Update")
                    .foregroundColor(.accentColor)
                    .bold()
                    .disabled(viewModel.name.isEmpty || viewModel.isSaving)
                    .onTapGesture {
                        updateData()
                    }
            }
        }
        .alert(isPresented: $viewModel.deleteDialog) {
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
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
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
    
    func delete() {
        Task {
            await viewModel.deleteCategory()
        }
    }
    
    func promoteDelete() {
        viewModel.deleteDialog.toggle()
    }
    
    func updateData() {
        viewModel.updateData()
    }
    
    
}
