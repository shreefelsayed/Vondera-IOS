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
    @State var saving = false
    @State var msg:String?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            ForEach(listPhotos, id: \.id) { item in
                if let index = listPhotos.firstIndex(where: { image in image.id == item.id }) {
                    ImageRow(pathOrLink: item, title: "Cover", index: index)
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    // --> Remove it from picker
                    if let _ = listPhotos[index].image {
                        images.remove(at: listPhotos[index].index)
                    }
                    
                    // --> Remove it from list
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
                        let photos = await newValue.addToListPhotos(list: listPhotos)
                        DispatchQueue.main.async {
                            self.listPhotos = photos
                        }
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
        .listStyle(.plain)
        .willProgress(saving: saving)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    update()
                }
                .disabled(saving)
            }
        }
        .navigationBarBackButtonHidden(saving)
        .task {
            if let siteData = user.user?.store?.siteData {
                self.listPhotos = siteData.listCover?.convertImageUrlsToItems() ?? []
            }
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg)
        }
        .navigationTitle("Cover photos")
    }
    
    func update() {
        if let storeId = user.user?.storeId {
            saving = true
            
            guard !listPhotos.isEmpty else {
                updateURL()
                return
            }
            
            
            FirebaseStorageUploader().uploadImagesToFirebaseStorage(images: listPhotos.getItemsToUpload().map { $0.image! }, storageRef: "stores/\(storeId)/cover/") { imageURLs, error in
                if let error = error {
                    self.saving = false
                    self.msg = error.localizedDescription
                } else if let urls = imageURLs {
                    self.listPhotos = self.listPhotos.mapUrlsToLinks(urls: urls)
                    self.updateURL()
                }
            }
        }
    }
    
    func updateURL() {
        Task {
            if let id = UserInformation.shared.user?.storeId {
                let data = [
                    "siteData.listCover" : listPhotos.getLinks(),
                ]
                
                if let _ = try? await StoresDao().update(id: id, hashMap: data) {
                    DispatchQueue.main.async { [self] in
                        UserInformation.shared.user?.store?.siteData?.listCover = listPhotos.getLinks()
                        UserInformation.shared.updateUser()
                        presentationMode.wrappedValue.dismiss()
                        msg = "Updated"
                    }
                } else {
                    msg = "Error Happened"
                }
                
                saving = false
            }
        }
    }
}

#Preview {
    WebsiteCover()
}
