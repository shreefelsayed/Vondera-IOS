//
//  ProductPhotos.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import SwiftUI
import PhotosUI

struct ProductPhotos: View {
    @Binding var product: StoreProduct
    @State private var images = [PhotosPickerItem]()
    @State private var imagesWithIndexs = [(PhotosPickerItem, Int)]()
    
    @State private var listPhotos = [ImagePickerWithUrL]()
    @State private var listOptamized = [String]()
    @State private var isSaving = false
    @State private var isLoading = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            ForEach(listPhotos, id: \.id) { item in
                if let index = listPhotos.firstIndex(where: { image in image.id == item.id }) {
                    ImageRow(pathOrLink: item, index: index)
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    // Remove from picker and from optimized list
                    if listPhotos[index].image != nil {
                        images.remove(at: listPhotos[index].index)
                    }
                    
                    listPhotos.remove(at: index)
                    listOptamized.remove(at: index)
                }
            }
            .onMove { indexSet, index in
                listPhotos.move(fromOffsets: indexSet, toOffset: index)
                listOptamized.move(fromOffsets: indexSet, toOffset: index)
            }
            
            if listPhotos.count < 6 {
                PhotosPicker(selection: $images, maxSelectionCount: (6 - listPhotos.count), matching: .images) {
                    Label("Add a new picture", systemImage: "plus")
                }
                .onChange(of: images) { newValue in
                    Task {
                        do {
                            let photos = try await newValue.addToListPhotos(list: listPhotos)
                            DispatchQueue.main.async {
                                self.listPhotos = photos
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            
            Text("At least choose 1 photo for your product, you can choose up to 6 photos, note that you can download them later easily.")
                .font(.caption)
        }
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .navigationTitle("Product photos")
        .navigationBarBackButtonHidden(isSaving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    uploadPhotos()
                }
                .disabled(isLoading || isSaving || listPhotos.isEmpty)
            }
        }
        .task {
            await getData()
        }
    }

    func getData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        
        do {
            let product = try await ProductsDao(storeId: storeId).getProduct(id: product.id)
            if let product = product {
                DispatchQueue.main.async {
                    self.product = product
                    self.listPhotos = product.listPhotos.convertImageUrlsToItems()
                    self.listOptamized = product.listOptamized ?? []
                    
                    // Ensure listOptamized has the same size as listPhotos
                    if self.listOptamized.count < self.listPhotos.count {
                        self.listOptamized.append(contentsOf: Array(repeating: "", count: self.listPhotos.count - self.listOptamized.count))
                    } else if self.listOptamized.count > self.listPhotos.count {
                        self.listOptamized = Array(self.listOptamized.prefix(self.listPhotos.count))
                    }
                    
                    self.isLoading = false
                }
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    func uploadPhotos() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        guard listPhotos.count > 0 else {
            ToastManager.shared.showToast(msg: "The product must have at least one photo", toastType: .error)
            return
        }
        
        self.isSaving = true
        
        let items = listPhotos.getItemsToUpload()
        if items.isEmpty {
            saveProduct()
            return
        }
        
        let imagesToUpload = items.map { $0.image! }
        S3Handler.uploadImages(imagesToUpload: imagesToUpload,
                               maxSizeMB: 4,
                               path: "stores/\(storeId)/products/\(product.id)",
                               createThumbnail: true) { imageLinks in
            DispatchQueue.main.async {
                listPhotos = listPhotos.mapUrlsToLinks(urls: imageLinks.0)
                listOptamized = imageLinks.1.compactMap { $0 }
                saveProduct()
            }
        }
    }
    
    func saveProduct() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        
        Task {
            do {
                let links = listPhotos.getLinks()
                let map: [String: Any] = ["listPhotos": links, "listOptamized": listOptamized]
                try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: map)
                
                DispatchQueue.main.async {
                    self.product.listPhotos = links
                    ToastManager.shared.showToast(msg: "Product Images Changed", toastType: .success)
                    self.presentationMode.wrappedValue.dismiss()
                }
            } catch {
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            }
            
            self.isSaving = false
        }
    }
}

extension Array {
    mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        var removedItems = [Element]()
        for i in source.reversed() {
            removedItems.insert(remove(at: i), at: 0)
        }
        insert(contentsOf: removedItems, at: destination)
    }
}

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
                        .centerCropped()
                        .id(image)
                }
            }
            .frame(width: 80)
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.trailing, 12)
            .tag(pathOrLink.id)
            
            
            Spacer()
            
            Image(systemName: "arrow.up.arrow.down")
                .opacity(0.5)
                .font(.body)
        }
    }
}

struct ImagePickerWithUrL  : Identifiable {
    var id = UUID().uuidString
    var image:UIImage?
    var link:String?
    var index:Int
}
