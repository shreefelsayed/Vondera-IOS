//
//  VarientsSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 18/04/2024.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore

struct VarientsSettings: View {
    @Binding var product:StoreProduct
    
    @State private var varientDetails = [VariantsDetails]()
    
    @State private var isLoading = false
    @State private var isSaving = false
    
    @State private var pickedImages:[PhotosPickerItem?] = []
    @State private var selectedImages:[UIImage?] = []
    
    @State private var urls:[String] = []
    @State private var newStock:[String] = []
    @State private var price:[String] = []
    @State private var cost:[String] = []
    
    @Environment(\.presentationMode) private var presentationMode


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                
                Text("You can optionaly upload an image to each varient")
                    .font(.caption)
                    .padding(.bottom, 12)
                
                
                if !varientDetails.isEmpty {
                    ForEach(varientDetails.indices, id: \.self) { index in
                        let item = varientDetails[index]
                        
                        HStack {
                            PhotosPicker(selection: $pickedImages[index]) {
                                Group {
                                    if let uiImage = selectedImages[index] {
                                        Image(uiImage: uiImage)
                                            .centerCropped()
                                        
                                    } else {
                                        CachedImageView(imageUrl: urls[index], scaleType: .centerCrop, placeHolder: UIImage(resource: .products))
                                    }
                                }
                                
                                .frame(width: 60, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor, lineWidth: 1.5)
                                )
                                .overlay {
                                    Image(.btnCamera)
                                        .opacity(0.6)
                                }
                                .overlay(alignment: .topLeading) {
                                    if pickedImages[index] != nil || urls[index] != "" {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(Color.white)
                                            .padding(4)
                                            .clipShape(Circle())
                                            .background(Circle().fill(.red))
                                            .offset(x: -8, y: -14)
                                            .onTapGesture {
                                                pickedImages[index] = nil
                                                urls[index] = ""
                                            }
                                    }
                                }
                            }
                            
                            
                            
                            VStack(alignment: .leading) {
                                Text(item.formatOptions())
                                    .bold()
                                    .padding(.bottom, 6)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Price")
                                        
                                        TextField("Price", text: $price[index])
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Cost")
                                        TextField("Cost", text: $cost[index])
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    
                                    if let stocked = product.alwaysStocked, !stocked {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Quantity")
                                            
                                            TextField("Quantity", text: $newStock[index])
                                                .textFieldStyle(.roundedBorder)
                                        }
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    }
                }
               
            }
        }
        .padding()
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .onChange(of: pickedImages) { newValue in
            Task {
                var uiImages = [UIImage?]()
                for photoImage in newValue {
                    if let photoImage = photoImage {
                        if let image = try? await photoImage.getImage() {
                            uiImages.append(image)
                        } else {
                            uiImages.append(nil)
                        }
                    } else {
                        uiImages.append(nil)
                    }
                }
                
                DispatchQueue.main.async {
                    self.selectedImages = uiImages
                }
            }
        }
        .task {
            await getData()
        }
        .navigationTitle("Customize Varients")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
            }
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
                    migrateOptions()
                    self.isLoading = false
                }
            }
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
    }
    
    func migrateOptions() {
        self.isLoading = true
        self.varientDetails = product.getVariant()
        let count = varientDetails.count
        
        for item in varientDetails {
            urls.append(item.image)
            newStock.append("\(item.quantity)")
            price.append("\(item.price)")
            cost.append("\(item.cost)")
        }
        
        pickedImages = Array(repeating: nil, count: count)
        selectedImages = Array(repeating: nil, count: count)
    
        self.isLoading = false
    }
    
    
    // MARK : Get the list to upload
    func getList() -> [VariantsDetails] {
        var items = [VariantsDetails]()
        for (index, item) in varientDetails.enumerated() {
            items.append(VariantsDetails(options: item.options, quantity: newStock[index].toInt, sold:0, image: urls[index], cost: cost[index].toDouble, price: price[index].toDouble))
        }
        
        return items
    }
    
    func save() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isSaving = true
        
        uploadPhotos {
            Task {
                let items = getList()
                do {
                    let quantity = (product.alwaysStocked ?? false) ? 0 : items.totalQuantity()
                    let map:[String:[VariantsDetails]] = ["variantsDetails": items]
                    let encoded: [String: Any] = try! Firestore.Encoder().encode(map)
                    try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: encoded)
                    try await ProductsDao(storeId: storeId).update(id: product.id, hashMap: ["quantity": quantity])
                    
                    DispatchQueue.main.async {
                        self.product.variantsDetails = items
                        self.product.quantity = quantity
                        self.isSaving = false
                        ToastManager.shared.showToast(msg: "Variants updated", toastType: .success)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
                    self.isSaving = false
                }
            }
        }
    }
    
    func uploadPhotos(completion: @escaping () -> Void) {
        guard let storeId = UserInformation.shared.user?.storeId else {
            completion() // Call completion immediately if storeId is nil
            return
        }
        
        // Create a DispatchGroup
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in selectedImages.enumerated() {
            if let image = image {
                // Enter the DispatchGroup
                dispatchGroup.enter()
                
                S3Handler.singleUpload(image: image, path: "stores/\(storeId)/products/\(product.id)/varients/\(UUID().uuidString).jpg", maxSizeMB: 2.5) { link in
                    defer {
                        // Leave the DispatchGroup regardless of success or failure
                        dispatchGroup.leave()
                    }
                    
                    self.urls[index] = link ?? ""
                }
            }
        }
        
        // Notify when all tasks in the DispatchGroup have completed
        dispatchGroup.notify(queue: .main) {
            completion() // Call completion after all images are uploaded
        }
    }
}

#Preview {
    VarientsSettings(product: .constant(StoreProduct.example()))
}
