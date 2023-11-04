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
import SwiftUI

class CreateCategoryViewModel : ObservableObject {
    var storeId:String
    
    var categoryDao:CategoryDao
    @Published var selectedImage: UIImage?
    @Published var name = ""
    @Published var desc = ""

    @Published var category:Category?

    @Published var msg:LocalizedStringKey?
    @Published var isSaving = false
    
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
                    self.showMessage(error.localizedDescription.localize())
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
            let myUser = UserInformation.shared.getUser()
            var created = Category(id: "",name: name, url: url.absoluteString, sortValue: myUser?.store!.categoriesCount ?? 0)
            created.desc = desc
            
            try await categoryDao.add(category: &created)
            
            // --> Saving Local
            
            if myUser?.storeId == storeId {
                if var categoriesCount = myUser?.store?.categoriesCount {
                    categoriesCount = categoriesCount + 1
                    myUser?.store?.categoriesCount = categoriesCount
                    UserInformation.shared.updateUser(myUser)
                }
            }

            
            DispatchQueue.main.async { [created] in
                print("category created")
                self.category = created
                self.shouldDismissView = true
                self.isSaving = false
            }
        } catch {
            print("error happened \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showMessage(error.localizedDescription.localize())
                self.isSaving = false
            }
        }
    }
    
    private func showMessage(_ msg: LocalizedStringKey) {
        self.msg = msg
    }
}
