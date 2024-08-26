//
//  WebsiteCover.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast
import PhotosUI

struct WebsiteCover: View {
    @State var listPhotos = [ImagePickerWithUrL]()
    @State var images = [PhotosPickerItem]()

    @ObservedObject var user = UserInformation.shared
    @State var isSaving = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            ForEach(listPhotos, id: \.id) { item in
                if let index = listPhotos.firstIndex(where: { image in image.id == item.id }) {
                    CoverImageRow(pathOrLink: item, title: "Cover", index: index)
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    // --> Remove it from picker
                    if listPhotos[index].image != nil {
                        images.remove(at: listPhotos[index].index)
                    }
                    
                    listPhotos.remove(at: index)
                }
                
            }
            .onMove { indexSet, index in
                listPhotos.move(fromOffsets: indexSet, toOffset: index)
            }
            
            if(listPhotos.count < 6) {
                PhotosPicker(selection: $images, maxSelectionCount: (6 - listPhotos.count), matching: .images) {
                    Label("Add a new picture", systemImage: "plus")
                }
                .onChange(of: images) { newValue in
                    Task {
                        let photos = try? await newValue.addToListPhotos(list: listPhotos)
                        DispatchQueue.main.async { self.listPhotos = photos ?? [] }
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .willProgress(saving: isSaving)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(isSaving)
            }
        }
        .task {
            if let siteData = user.user?.store?.siteData {
                self.listPhotos = siteData.listCover?.convertImageUrlsToItems() ?? []
            }
        }
        .navigationTitle("Cover photos")
    }
    
    func update() {
        // Make sure you have items to upload
        guard !listPhotos.getItemsToUpload().isEmpty else {
            updateURL()
            return
        }
        
        guard let storeId = user.user?.storeId else {
            return
        }
        
        isSaving = true
        
        let itemsToUpload = listPhotos.getItemsToUpload().map { $0.image! }
        
        S3Handler.uploadImages(imagesToUpload: itemsToUpload, maxSizeMB: 4, path: "stores/\(storeId)/cover/", createThumbnail: false) { uploadedUrls in
            self.listPhotos = self.listPhotos.mapUrlsToLinks(urls: uploadedUrls.0)
            self.updateURL()
        }
        
    }
    
    func updateURL() {
        guard let id = UserInformation.shared.user?.storeId else { return }
        
        isSaving = true
        let data = ["siteData.listCover" : listPhotos.getLinks()]
        
        Task {
            do {
                try await StoresDao().update(id: id, hashMap: data)
                DispatchQueue.main.async {
                    UserInformation.shared.user?.store?.siteData?.listCover = listPhotos.getLinks()
                    UserInformation.shared.updateUser()
                    ToastManager.shared.showToast(msg: "Covers Updated", toastType: .success)
                    self.presentationMode.wrappedValue.dismiss()
                }
            } catch {
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
                CrashsManager().addLogs(error.localizedDescription, "Website Covers")
            }
            
            DispatchQueue.main.async {
                isSaving = false
            }
        }
    }
}

struct CoverImageRow: View {
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
            //.aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: 140)
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

#Preview {
    WebsiteCover()
}
