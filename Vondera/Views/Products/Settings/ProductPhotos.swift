//
//  ProductPhotos.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import AlertToast
import PhotosUI

struct ImageRow: View {
    var pathOrLink: ImagePickerWithUrL
    var title:String = "Product"
    var index:Int
    
    var body: some View {
        HStack {
            Group {
                if let link = pathOrLink.link  {
                    CachedImageView(imageUrl: link, scaleType: .centerCrop)
                    .id(link)
                } else if let image = pathOrLink.image {
                    Image(uiImage: image)
                        .resizable()
                        .id(image)
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 180, height: 100)
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1))
            .padding(.trailing, 12)
            .tag(pathOrLink.id)
            
            
            Text("Image (\((index + 1)))")
            
            Spacer()
            
            Image(systemName: "arrow.up.arrow.down")
                .opacity(0.5)
                .font(.body)
        }
    }
}

struct ImagePickerWithUrL  : Identifiable{
    var id = UUID().uuidString
    var image:UIImage?
    var link:String?
    var index:Int
}

struct ProductPhotos: View {
    var product:StoreProduct
    @State var images = [PhotosPickerItem]()
    @State var imagesWithIndexs = [(PhotosPickerItem, Int)]()
    
    @ObservedObject var viewModel:ProductPhotosViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(product: StoreProduct) {
        self.product = product
        self.viewModel = ProductPhotosViewModel(product: product)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.listPhotos, id: \.id) { item in
                if let index = viewModel.listPhotos.firstIndex(where: { image in image.id == item.id }) {
                    ImageRow(pathOrLink: item, index: index)
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    // --> Remove it from picker
                    if let image = viewModel.listPhotos[index].image {
                        images.remove(at: viewModel.listPhotos[index].index)
                    }
                    
                    // --> Remove it from list
                    viewModel.listPhotos.remove(at: index)
                }
                
            }
            .onMove { indexSet, index in
                viewModel.listPhotos.move(fromOffsets: indexSet, toOffset: index)
            }
            
            if(viewModel.listPhotos.count < 6) {
                PhotosPicker(selection: $images, maxSelectionCount: (6 - viewModel.listPhotos.count), matching: .images) {
                    Label("Add a new picture", systemImage: "plus")
                }
                .onChange(of: images) { newValue in
                    Task {
                        let photos = await newValue.addToListPhotos(list: viewModel.listPhotos)
                        DispatchQueue.main.async {
                            self.viewModel.listPhotos = photos
                        }
                    }
                }
            }
            
            Text("At least choose 1 photo for your product, you can choose up to 6 photos, note that you can download them later easily.")
                .font(.caption)
        }
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .navigationTitle("Product photos")
        .navigationBarBackButtonHidden(viewModel.isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(viewModel.isLoading || viewModel.isSaving || product.listPhotos.isEmpty)
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
    
}

struct ProductPhotos_Previews: PreviewProvider {
    static var previews: some View {
        ProductPhotos(product: StoreProduct.example())
    }
}
