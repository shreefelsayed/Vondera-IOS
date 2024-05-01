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
        // Make sure you have items to upload
        guard !listPhotos.getItemsToUpload().isEmpty else {
            updateURL()
            return
        }
        
        guard let storeId = user.user?.storeId else {
            return
        }
        
        self.saving = true
        
        // Upload the items
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
    
    func updateURL() {
        guard let id = UserInformation.shared.user?.storeId  else {
            return
        }
        
        self.saving = true
        print("Saving new urls")
        
        let data = [
            "siteData.listCover" : listPhotos.getLinks(),
        ]
        
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
                self.saving = false
            }
        }
    }
}

#Preview {
    WebsiteCover()
}
