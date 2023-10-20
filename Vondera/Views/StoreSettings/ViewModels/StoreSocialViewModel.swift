//
//  StoreSocialViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import Combine

class StoreSocialViewModel : ObservableObject {
    var store:Store
    var storesDao = StoresDao()
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var showToast = false
    @Published var msg = ""
    @Published var fb = ""
    @Published var insta = ""
    @Published var web = ""
    @Published var tiktok = ""

    @Published var isSaving = false
    
    
    init(store:Store) {
        self.store = store
        self.fb = store.fbLink ?? ""
        self.insta = store.instaLink ?? ""
        self.web = store.website ?? ""
        self.tiktok = store.tiktokLink ?? ""

    }
    
    func updateName() async {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            try await storesDao.update(id: store.ownerId, hashMap: ["fbLink": fb, "instaLink":insta,"website": web, "tiktokLink":tiktok])
            
            store.fbLink = fb
            store.tiktokLink = tiktok
            store.instaLink = insta
            store.website = web

            // Saving local
            if var myUser = UserInformation.shared.getUser() {
                myUser.store = store
                UserInformation.shared.updateUser(myUser)
            }
            
            showTosat(msg: "Social Links Changed")
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
    
    func showTosat(msg: String) {
        self.msg = msg
        showToast.toggle()
    }
}
