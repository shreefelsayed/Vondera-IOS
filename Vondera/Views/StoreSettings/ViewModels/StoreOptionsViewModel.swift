//
//  StoreOptionsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 26/06/2023.
//

import Foundation
import Combine

class StoreOptionsViewModel: ObservableObject {
    var store:Store
    var storesDao = StoresDao()
    
    @Published var ordering:Bool = false
    @Published var offline:Bool = false
    @Published var prepaid:Bool = false
    @Published var attachments:Bool = false
    @Published var label:Bool = false
    @Published var whatsapp:Bool = false
    @Published var chat:Bool = false
    @Published var website:Bool = false
    
    @Published var editPrice:Bool = false
    @Published var indec:String = ""
    @Published var reset = false
    
    @Published var isSaving:Bool = false
    @Published var showToast:Bool = false
    @Published var msg:String = ""
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    init(store:Store) {
        self.store = store
        ordering = store.canOrder ?? true
        offline = !(store.onlyOnline ?? true)
        prepaid = store.canPrePaid ?? true
        attachments = store.orderAttachments ?? true
        label = store.cantOpenPackage ?? false
        whatsapp = store.localWhatsapp ?? true
        website = store.websiteEnabled ?? false
        chat = store.chatEnabled ?? true
        reset = store.canWorkersReset ?? false
        editPrice = store.canEditPrice ?? false
        indec = "\(store.almostOut ?? 20)"
    }
    
    func save() async {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:Any] = ["canOrder": ordering,
                                    "onlyOnline":!offline,
                                    "websiteEnabled":website,
                                    "canPrePaid":prepaid,
                                    "orderAttachments":attachments,
                                    "cantOpenPackage":label,
                                    "localWhatsapp":whatsapp,
                                    "chatEnabled":chat,
                                    "canWorkersReset":reset,
                                    "canEditPrice":editPrice,
                                    "almostOut":Int(indec)!]
            
            try await storesDao.update(id: store.ownerId, hashMap: map)
            store.canOrder = map["canOrder"] as? Bool ?? false
            store.onlyOnline = !(map["onlyOnline"] as? Bool ?? true)
            store.websiteEnabled = map["websiteEnabled"] as? Bool ?? false
            store.canPrePaid = map["canPrePaid"] as? Bool ?? false
            store.orderAttachments = map["orderAttachments"] as? Bool ?? true
            store.cantOpenPackage = map["cantOpenPackage"] as? Bool ?? false
            store.localWhatsapp = map["localWhatsapp"] as? Bool ?? true
            store.chatEnabled = map["chatEnabled"] as? Bool ?? false
            store.canWorkersReset = map["canWorkersReset"] as? Bool ?? false
            store.canEditPrice = map["canEditPrice"] as? Bool ?? false
            store.almostOut = map["almostOut"] as? Int ?? 0
            
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
