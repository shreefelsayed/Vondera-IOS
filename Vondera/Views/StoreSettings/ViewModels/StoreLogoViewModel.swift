//
//  StoreLogoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import Combine
import FirebaseStorage
import PhotosUI

class StoreLogoViewModel : NSObject, ObservableObject, PHPickerViewControllerDelegate {
    var store:Store
    var storesDao = StoresDao()
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var link = ""
    @Published var selectedImage: UIImage?

    @Published var msg = ""
    @Published var isSaving = false
    @Published var showToast = false

    
    init(store:Store) {
        self.store = store
        self.link = store.logo ?? ""
    }
    
    
    func saveNewLogo() async {
        // --> Check if image wasn't selected
        guard selectedImage != nil else {
            showMessage("Please select the new logo")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        print("Uploading image")
        
        // --> Upload the new Image
        let ref = Storage.storage().reference().child("stores")
        FirebaseStorageUploader().oneImageUpload(image: selectedImage! ,name: "\(String(describing: store.ownerId)) - Logo" ,ref: ref) { url, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.showMessage(error.localizedDescription)
                }
                
            } else if let url = url {
                print("New logo uploaded")
                self.updateRef(url: url)
            }
        }
    }
    
    private func updateRef(url:URL) {
        Task {
            do {
                try await storesDao.update(id: store.ownerId, hashMap: ["logo": url.absoluteString])
                store.logo = url.absoluteString
                
                // Saving local
                var myUser = await LocalInfo().getLocalUser()
                if myUser!.storeId == store.ownerId {
                    myUser!.store!.logo = url.absoluteString
                    _ = await LocalInfo().saveUser(user: myUser!)
                }
                
                showMessage("Store Logo Changed")
                print("New logo url updated")
                DispatchQueue.main.async {
                    self.shouldDismissView = true
                }
            } catch {
                showMessage(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self.isSaving = false
            }
        }
    }
    
    private func showMessage(_ msg: String) {
        self.msg = msg
        showToast.toggle()
    }
    
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.selectedImage = image
                        }
                    }
                }
            }
        }
    }
    
    func pickPhotos() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        configuration.selection = .ordered
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        // Present the photo picker
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
    
}

