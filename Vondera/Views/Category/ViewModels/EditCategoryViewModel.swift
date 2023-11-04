//
//  EditCategoryViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 31/08/2023.
//

import Foundation
import Combine
import FirebaseStorage
import PhotosUI

class EditCategoryViewModel : NSObject, ObservableObject, PHPickerViewControllerDelegate {
    var storeId:String
    var category:Category
    var categoryDao:CategoryDao

    @Published var name:String = ""
    @Published var desc:String = ""
    @Published var link:String = ""
    @Published var selectedImage:UIImage?
    
    @Published var deleteDialog = false
    @Published var msg:String?
    @Published var isSaving = false
    
    init(storeId: String, category:Category) {
        self.storeId = storeId
        self.category = category
        self.categoryDao = CategoryDao(storeId: storeId)
        
        self.name = category.name
        self.link = category.url
        self.desc = category.desc ?? ""
    }
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    func updateData() {
        self.isSaving = true
        
        Task {
            if selectedImage == nil {
                setData()
            } else {
                uploadImage()
            }
        }
    }
    
    func setData() {
        Task {
            let data:[String:Any] = ["name": name, "url" : link, "desc": desc]
            try! await categoryDao.update(id: category.id, hash: data)
            
            self.category.name = name
            self.category.url = link
            self.category.desc = desc
            
            DispatchQueue.main.async {
                print("category Updated")
                self.isSaving = false
                self.shouldDismissView = true
            }
        }
    }
    
    func deleteCategory() async {
        self.isSaving = true
        try! await categoryDao.delete(id: category.id)
        
        DispatchQueue.main.async {
            print("category Deleted")
            self.isSaving = false
            self.shouldDismissView = true
        }
    }
    
    func uploadImage() {
        let ref = Storage.storage().reference().child("stores").child(storeId)
        FirebaseStorageUploader().oneImageUpload(image: selectedImage! ,name: name ,ref: ref) { url, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.msg = error.localizedDescription
                    self.isSaving = false
                }
            } else if let url = url {
                self.link = url.absoluteString
                self.setData()
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

        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
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
}
