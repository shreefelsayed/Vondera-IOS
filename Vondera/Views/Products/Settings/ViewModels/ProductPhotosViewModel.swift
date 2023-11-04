//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine
import FirebaseStorage
import PhotosUI

class ProductPhotosViewModel : ObservableObject {
    @Published var product:StoreProduct
    var productsDao:ProductsDao
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    var canAdd:Bool {
        return (listPhotos.count + selectedPhotos.count) < 6
    }
    
    @Published var listPhotos = [String]()
    @Published var selectedPhotos: [UIImage] = []

    @Published var isSaving = false
    @Published var isLoading = false

    @Published var showToast = false
    var myUser = UserInformation.shared.getUser()
    @Published var msg = ""
    
    init(product:StoreProduct) {
        self.product = product
        self.productsDao = ProductsDao(storeId: product.storeId)
        self.myUser = UserInformation.shared.getUser()
        
        Task {
            await getData()
        }
    }
    
    
    func removePhoto(image: String) {
        if let index = listPhotos.firstIndex(of: image) {
            listPhotos.remove(at: index)
        }
    }
    
    func removePhoto(image: UIImage) {
        if let index = selectedPhotos.firstIndex(of: image) {
            selectedPhotos.remove(at: index)
        }
    }
    
    func clearSelectedPhotos() {
        selectedPhotos.removeAll()
    }
        
    
    func getData() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        if let product = try? await productsDao.getProduct(id: product.id) {
            DispatchQueue.main.async {
                self.product = product
                self.listPhotos = product.listPhotos
                self.isLoading = false
            }
        } else {
            DispatchQueue.main.async {
                self.showTosat(msg: "Product doesn't Exist")
                self.shouldDismissView = true
            }
        }
    }
    
    func uploadPhotos() {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        if selectedPhotos.isEmpty {
            saveProduct(uris: nil)
            return
        }
        
        
        
        if let storeId = myUser?.storeId {
            FirebaseStorageUploader().uploadImagesToFirebaseStorage(images: selectedPhotos, storageRef: "stores/\(storeId)/products\(product.id)") { imageURLs, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.isSaving = false
                        self.showTosat(msg: error.localizedDescription)
                    }
                } else if let imageURLs = imageURLs {
                
                    self.saveProduct(uris: imageURLs)
                }
            }
        }
        
    }
    
    func saveProduct(uris:[URL]?)  {
        Task {
            do {
                // --> Update the database
                var finalList = [String]()
                finalList.append(contentsOf: listPhotos)
                
                if uris != nil {
                    finalList.append(contentsOf: uris!.map { $0.absoluteString })
                }
                
                let map:[String:Any] = ["listPhotos": finalList]
                try await productsDao.update(id: product.id, hashMap: map)
                
                DispatchQueue.main.async {
                    self.showTosat(msg: "Product Images Changed")
                    self.shouldDismissView = true
                }
            } catch {
                showTosat(msg: error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self.isSaving = false
            }
        }
    }
    
    
    func update() async {
        let totalSize = (listPhotos.count + selectedPhotos.count)
        guard totalSize > 0 else {
            showTosat(msg: "The product must have at least one photo")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        uploadPhotos()
    }
    
    func showTosat(msg: String) {
        self.msg = msg
        showToast.toggle()
    }
}
