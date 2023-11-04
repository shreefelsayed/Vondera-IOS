//
//  StoreEditNameViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import Combine
import SwiftUI

class StoreEditNameViewModel : ObservableObject {
    var store:Store
    var storesDao = StoresDao()
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var msg:LocalizedStringKey?
    @Published var name = ""
    @Published var slogan = ""

    @Published var isSaving = false
    
    
    init(store:Store) {
        self.store = store
        self.name = store.name
        self.slogan = store.slogan ?? ""
    }
    
    func updateName() async {
        guard !name.isBlank else {
            showTosat(msg: "Fill your store name")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            try await storesDao.update(id: store.ownerId, hashMap: ["name": name, "slogan":slogan])
            store.name = name
            
            // Saving local
            if var myUser = UserInformation.shared.getUser() {
                myUser.store = store
                UserInformation.shared.updateUser(myUser)
                showTosat(msg: "Store Name Changed")
            }
            
            DispatchQueue.main.async {
                self.shouldDismissView = true
            }
        } catch {
            showTosat(msg: error.localizedDescription.localize())
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func showTosat(msg: LocalizedStringKey) {
        self.msg = msg
    }
}
