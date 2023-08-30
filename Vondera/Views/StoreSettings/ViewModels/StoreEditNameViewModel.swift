//
//  StoreEditNameViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/06/2023.
//

import Foundation
import Combine

class StoreEditNameViewModel : ObservableObject {
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
            var myUser = await LocalInfo().getLocalUser()
            if myUser!.storeId == store.ownerId {
                myUser!.store = self.store
                _ = await LocalInfo().saveUser(user: myUser!)
            }
            
            showTosat(msg: "Store Name Changed")
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
