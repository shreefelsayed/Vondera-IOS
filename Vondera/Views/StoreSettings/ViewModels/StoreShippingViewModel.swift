//
//  StoreShippingViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 06/07/2023.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI
class StoreShippingViewModel : ObservableObject {
    var storeId:String
    var storesDao = StoresDao()
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var store:Store?
    @Published var list = [CourierPrice]()
    @Published var isSaving = false
    @Published var isLoading = false
    
    @Published var msg:LocalizedStringKey?
    
    init(storeId:String) {
        self.storeId = storeId
            
        // --> Set the published values
        Task {
            await getData()
        }
    }
    
    func getData() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            if let storeId = UserInformation.shared.user?.storeId {
                let store = try await storesDao.getStore(uId: storeId)
                if let list = store.listAreas {
                    DispatchQueue.main.async {
                        self.list = list.uniqueElements()
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
            CrashsManager().addLogs(error.localizedDescription, "Store Shipping")
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func update() async {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:[CourierPrice]] = ["listAreas": list.uniqueElements()]
            let encoded: [String: Any]
            encoded = try! Firestore.Encoder().encode(map)
            
            try await storesDao.update(id: storeId, hashMap: encoded)
            
            
            DispatchQueue.main.async {
                UserInformation.shared.user?.store?.listAreas = self.list.uniqueElements()
                UserInformation.shared.updateUser()
                
                self.showToast("Store Shipping info changed".localize())
                self.shouldDismissView = true
            }
        } catch {
            showToast(error.localizedDescription.localize())
            CrashsManager().addLogs(error.localizedDescription, "Store Shipping")

        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func showToast(_ msg: LocalizedStringKey) {
        self.msg = msg
    }
}
