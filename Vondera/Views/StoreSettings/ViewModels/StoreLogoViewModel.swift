//
//  StoreLogoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import Combine
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
    
    
    @MainActor
    func saveNewLogo() {
        // --> Check if image wasn't selected
        guard selectedImage != nil else {
            isSaving = false
            showMessage("Please select the new logo")
            return
        }
        
        // --> Upload the new Image
        guard let image = selectedImage, let user = UserInformation.shared.user else {
            isSaving = false
            showMessage("Please repick the image")
            return
        }

        isSaving = true
        
        S3Handler.singleUpload(image: image,
                               path: "stores/\(user.storeId)/icon.jpg",
                               maxSizeMB: 0.3) { link in
            if let link = link {
                self.updateRef(url: link)
            } else {
                self.isSaving = false
                self.showMessage("Error Updating image")
            }
        }
    }
    
    private func updateRef(url:String) {
        Task {
            do {
                try await storesDao.update(id: store.ownerId, hashMap: ["logo": url])
                store.logo = url
                
                // Saving local
                if let myUser = UserInformation.shared.getUser() {
                    myUser.store?.logo = url
                    UserInformation.shared.updateUser(myUser)                    
                }
                                
                DispatchQueue.main.async {
                    self.showMessage("Store Logo Changed")
                    self.shouldDismissView = true
                }
            } catch {
                CrashsManager().addLogs(error.localizedDescription, "Store Shipping")
            }
            
            DispatchQueue.main.async {
                self.isSaving = false
            }
        }
    }
    
    private func showMessage(_ msg: LocalizedStringKey) {
        self.msg = msg
    }
}

