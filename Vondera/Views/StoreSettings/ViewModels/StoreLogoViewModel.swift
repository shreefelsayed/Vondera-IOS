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
import SwiftUI

class StoreLogoViewModel : ObservableObject {
    var store:Store
    var storesDao = StoresDao()
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var link = ""
    @Published var selectedImage: UIImage? = nil

    @Published var msg:LocalizedStringKey?
    @Published var isSaving = false

    
    init(store:Store) {
        self.store = store
        self.link = store.logo ?? ""
    }
    
    
    func saveNewLogo() {
        // --> Check if image wasn't selected
        guard selectedImage != nil else {
            isSaving = false
            showMessage("Please select the new logo")
            return
        }
        
        // --> Upload the new Image
        let ref = Storage.storage().reference().child("stores")
        
        guard let image = selectedImage else {
            isSaving = false
            showMessage("Please repick the image")
            return
        }

        if selectedImage != nil {
            isSaving = true
            FirebaseStorageUploader().oneImageUpload(image: image, ref: "stores/\(String(describing: store.ownerId)) - Logo.jpeg") { [self] url, error in
                if let error = error {
                    isSaving = false
                    showMessage(error.localizedDescription.localize())
                } else if let url = url {
                    updateRef(url: url)
                }
            }
        }
    }
    
    private func updateRef(url:URL) {
        Task {
            do {
                try await storesDao.update(id: store.ownerId, hashMap: ["logo": url.absoluteString])
                store.logo = url.absoluteString
                
                // Saving local
                if let myUser = UserInformation.shared.getUser() {
                    myUser.store?.logo = url.absoluteString
                    UserInformation.shared.updateUser(myUser)

                    // Call the firebase function
                    let data:[String:Any] = ["mid" : myUser.store?.merchantId ?? "", "link" : url.absoluteString]
                    
                    
                    _ = try await FirebaseFunctionCaller().callFunction(functionName: "sheets-logoChanged", data: data)
                }
                                
                DispatchQueue.main.async {
                    self.showMessage("Store Logo Changed")
                    self.isSaving = false
                    self.shouldDismissView = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSaving = false
                    self.showMessage(error.localizedDescription.localize())
                }
            }
        }
    }
    
    private func showMessage(_ msg: LocalizedStringKey) {
        self.msg = msg
    }
}

