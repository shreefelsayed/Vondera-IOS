//
//  ProductInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 02/07/2023.
//

import Foundation
import Combine
import PhotosUI
import FirebaseStorage

class ProductPhotosViewModel : NSObject, ObservableObject, PHPickerViewControllerDelegate {
    @Published var product:Product
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
    @Published var msg = ""
    
    init(product:Product) {
        self.product = product
        self.productsDao = ProductsDao(storeId: product.storeId)
        super.init()
        
        // --> Set the published values
        load()
    }
    
    func load() {
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
    
    // Add a function to clear the selected photos
    func clearSelectedPhotos() {
        selectedPhotos.removeAll()
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.selectedPhotos.append(image)
                        }
                    }
                }
            }
        }
    }
        
    func pickPhotos() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 6 - (selectedPhotos.count + listPhotos.count)
        configuration.filter = .images
        configuration.selection = .ordered
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        // Present the photo picker
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
    
    func getData() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            self.product = try await productsDao.getProduct(id: product.id)!
            self.listPhotos = product.listPhotos
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
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
        
        let storageRef = Storage.storage().reference().child("products").child(product.id)
        FirebaseStorageUploader().uploadImagesToFirebaseStorage(images: selectedPhotos, storageRef: storageRef) { imageURLs, error in
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
    
    func saveProduct(uris:[URL]?)  {
        Task {
            do {
                // --> Update the database
                var finalList = [String]()
                finalList.append(contentsOf: listPhotos)
                
                if uris != nil {
                    finalList.append(contentsOf: uris!.map { $0.absoluteString })
                }
                
                var map:[String:Any] = ["listPhotos": finalList]
                try await productsDao.update(id: product.id, hashMap: map)
                
                showTosat(msg: "Product Images Changed")
                DispatchQueue.main.async {
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
        var totalSize = (listPhotos.count + selectedPhotos.count)
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
