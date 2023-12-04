//
//  WebsiteCover.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/10/2023.
//

import SwiftUI
import AlertToast
import PhotosUI
import NetworkImage

struct WebsiteCover: View {
    
    @State var items = [String]()
    @State var images = [PhotosPickerItem]()
    @State var uiImages = [UIImage]()
    
    
    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:String?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { image in
                NetworkImageViewWithDeleteButton(imageUrl: URL(string: image)!) {
                    if let index = items.firstIndex(of: image) {
                        items.remove(at: index)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
            }
            
            ForEach(uiImages, id: \.self) { image in
                ImageViewWithDeleteButton(image: image) {
                    if let index = uiImages.firstIndex(of: image) {
                        uiImages.remove(at: index)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
            }
            
            if (images.count + items.count) < 6 {
                PhotosPicker(selection: $images, maxSelectionCount: (6 - (images.count + items.count)), matching: .images) {
                    ImageView(removeClicked: {
                    }, showDelete: false) {
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                }
            }
        }
        .listStyle(.plain)
        // MARK : Recive New Images
        .onChange(of: images) { newValue in
            Task {
                uiImages.removeAll()
                for picker in newValue {
                    if let image = try? await picker.getImage() {
                        uiImages.append(image)
                    }
                }
            }
        }
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
                items = siteData.listCover ?? []
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
            if !uiImages.isEmpty {
                FirebaseStorageUploader().uploadImagesToFirebaseStorage(images: uiImages, storageRef: "stores/\(storeId)/cover/") { imageURLs, error in
                    if let error = error {
                        self.saving = false
                        self.msg = error.localizedDescription
                    } else if let imageURLs = imageURLs {
                        self.updateURL(uris: imageURLs)
                    }
                }
            } else {
                updateURL(uris: [])
            }
        }
    }
    
    func updateURL(uris:[URL]) {
        Task {
            if let id = UserInformation.shared.user?.storeId {
                var finalList = uris.map({ $0.absoluteString })
                finalList.append(contentsOf: items)
                
                let data = [
                    "siteData.listCover" : finalList,
                ]
                
                if let _ = try? await StoresDao().update(id: id, hashMap: data) {
                    DispatchQueue.main.async { [self] in
                        UserInformation.shared.user?.store?.siteData?.listCover = finalList
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

struct NetworkImageViewWithDeleteButton: View {
    var imageUrl: URL
    var onDelete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: imageUrl) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(6/4, contentMode: .fit)
                            .cornerRadius(10)
                    } else if phase.error != nil {
                        Text("Image Load Error")
                    } else {
                        Color.gray
                    }
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                }
                .padding()
            }
        }
    }
}

struct ImageViewWithDeleteButton: View {
    var image: UIImage
    var onDelete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(6/4, contentMode: .fit)
                    .cornerRadius(10)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                }
                .padding()
            }
        }
    }
}
