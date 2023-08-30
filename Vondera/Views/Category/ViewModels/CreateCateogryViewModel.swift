//
//  CreateCateogryViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import Combine
import FirebaseStorage
import PhotosUI

class CreateCategoryViewModel : NSObject, ObservableObject, PHPickerViewControllerDelegate {
    var storeId:String
    
    var categoryDao:CategoryDao
    @Published var selectedImage: UIImage?
    @Published var name = ""
    @Published var category:Category?

    @Published var msg = ""
    @Published var isSaving = false
    @Published var showToast = false
    
    init(storeId: String) {
        self.storeId = storeId
        self.categoryDao = CategoryDao(storeId: storeId)
    }
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    func saveCategory() async {
        // --> Check if image wasn't selected
        guard selectedImage != nil else {
            showMessage("Please select a category image")
            self.isSaving = false
            pickPhotos()
            return
        }
        
        guard !name.isBlank else {
            showMessage("Please enter the category name")
            self.isSaving = false
            return
        }
        
        self.isSaving = true
        
        
        // --> Upload the new Image
        let ref = Storage.storage().reference().child("stores").child(storeId)
        FirebaseStorageUploader().oneImageUpload(image: selectedImage! ,name: name ,ref: ref) { url, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.showMessage(error.localizedDescription)
                }
            } else if let url = url {
                Task {
                    print("New logo uploaded")
                    await self.addCategory(url: url)
                }
                
            }
        }
    }
    
    func addCategory(url:URL) async {
        do {
            print("store id \(storeId)")
            var myUser = await LocalInfo().getLocalUser()
            var created = Category(id: "",name: name, url: url.absoluteString, sortValue: myUser?.store!.categoriesCount ?? 0)
            try await categoryDao.add(category: &created)
            
            // --> Saving Local
            
            if myUser?.storeId == storeId {
                if var categoriesCount = myUser?.store?.categoriesCount {
                    categoriesCount = categoriesCount + 1
                    myUser?.store?.categoriesCount = categoriesCount
                    _ = await LocalInfo().saveUser(user: myUser!)
                }
            }

            
            DispatchQueue.main.async {
                print("category created")
                self.category = created
                self.shouldDismissView = true
                self.isSaving = false
            }
        } catch {
            print("error happened \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showMessage(error.localizedDescription)
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
                        DispatchQueue.main.sync {
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
