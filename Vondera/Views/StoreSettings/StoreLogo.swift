//
//  StoreLogo.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import SwiftUI
import AlertToast
import PhotosUI

struct StoreLogo: View {
    var store:Store
    
    @State var pickedPhoto:PhotosPickerItem?
    @ObservedObject var viewModel:StoreLogoViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(store: Store) {
        self.store = store
        self.viewModel = StoreLogoViewModel(store: store)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                Text("Click on the below photo to pick your new logo")
                    .font(.title2)
                    .bold()
                
                PhotosPicker(selection: $pickedPhoto) {
                    ImagePickupHolder(currentImageURL: store.logo, selectedImage: viewModel.selectedImage, currentImagePlaceHolder: UIImage(named: "app_icon"), reduis: 120)
                }
                
                Spacer().frame(height: 20)
                
                Text("The store logo is used to identify your store in the app. It will be displayed on the store page and in the store list. The logo should be a square image with a minimum size of 512x512 pixels. The recommended size is 1024x1024 pixels. The logo will be displayed at a size of 120x120 pixels.")
                    .font(.caption)
            }
        }
        .padding()
        .navigationTitle("Store Logo")
        .onChange(of: pickedPhoto) { _ in
            Task {
                if let data = try? await pickedPhoto?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        viewModel.selectedImage = uiImage
                        return
                    }
                }
            }
        }
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    save()
                }
                .disabled(viewModel.isSaving || viewModel.selectedImage == nil)
            }
        }
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .willProgress(saving: viewModel.isSaving)
        .toast(isPresenting: Binding(value: $viewModel.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg?.toString())
        }
    }
    
    func save() {
        
        viewModel.saveNewLogo()
    }
}

struct StoreLogo_Previews: PreviewProvider {
    static var previews: some View {
        StoreLogo(store: Store.example())
    }
}
