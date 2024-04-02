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
        return listPhotos.count < 6
    }
    
    @Published var listPhotos = [ImagePickerWithUrL]()
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
    
        
    
    func getData() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        if let product = try? await productsDao.getProduct(id: product.id) {
            DispatchQueue.main.async {
                self.product = product
                self.listPhotos = product.listPhotos.convertImageUrlsToItems()
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
        
        if listPhotos.getItemsToUpload().isEmpty {
            saveProduct()
            return
        }
        
        
        if let storeId = myUser?.storeId {
            FirebaseStorageUploader().uploadImagesToFirebaseStorage(images: listPhotos.getItemsToUpload().map { $0.image! }, storageRef: "stores/\(storeId)/products/\(product.id)") { [self] urls, error in
                if let error = error {
                    isSaving = false
                    showTosat(msg: error.localizedDescription)
                } else if let urls = urls {
                    listPhotos = listPhotos.mapUrlsToLinks(urls: urls)
                    saveProduct()
                }
                
                
            }
        }
    }
    
    func saveProduct()  {
        Task {
            do {
                let map:[String:Any] = ["listPhotos": listPhotos.getLinks()]
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
        guard listPhotos.count > 0 else {
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
