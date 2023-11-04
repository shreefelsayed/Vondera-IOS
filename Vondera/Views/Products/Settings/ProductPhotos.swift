//
//  ProductPhotos.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast
import PhotosUI

struct ProductPhotos: View {
    var product:StoreProduct
    @State var images = [PhotosPickerItem]()
    @ObservedObject var viewModel:ProductPhotosViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductPhotosViewModel(product: product)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                photos
            }
            .isHidden(viewModel.isLoading)
        }
        .padding()
        .navigationTitle("Product photos")
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .isHidden(viewModel.isLoading)
            }
        }
        .overlay(alignment: .center, content: {
            ProgressView()
                .isHidden(!viewModel.isLoading)
        })
        .willProgress(saving: viewModel.isSaving)
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
    }
    
    func update() {
        Task {
            await viewModel.update()
        }
    }
    
    var photos: some View {
        VStack(alignment: .leading) {
            // MARK : Photos title
            HStack {
                Text("Product photos")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                PhotosPicker(selection: $images, maxSelectionCount: (6 - images.count), matching: .images) {
                    Text("Add")
                }
                .disabled(images.count >= 6)
            }
            
            // MARK : Selected Photos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.listPhotos, id: \.self) { image in
                        ImageViewNetwork(image: image) {
                            viewModel.removePhoto(image: image)
                        }
                    }
                    
                    ForEach(viewModel.selectedPhotos, id: \.self) { image in
                        ImageView(image: image, removeClicked: {
                            viewModel.removePhoto(image: image)
                        })
                    }
                    
                    if images.count < 6 {
                        PhotosPicker(selection: $images, maxSelectionCount: (6 - images.count), matching: .images) {
                            ImageView(removeClicked: {
                            }, showDelete: false) {
                                
                            }
                        }
                        .disabled(images.count >= 6)
                    }
                }
            }
            
            Text("At least choose 1 photo for your product, you can choose up to 6 photos, note that you can download them later easily.")
                .font(.caption)
        }
        .onChange(of: images) { newValue in
            Task {
                viewModel.selectedPhotos.removeAll()
                for picker in newValue {
                    if let image = try? await picker.getImage() {
                        viewModel.selectedPhotos.append(image)
                    }
                }
            }
        }
    }
}

struct ProductPhotos_Previews: PreviewProvider {
    static var previews: some View {
        ProductPhotos(product: StoreProduct.example())
    }
}
