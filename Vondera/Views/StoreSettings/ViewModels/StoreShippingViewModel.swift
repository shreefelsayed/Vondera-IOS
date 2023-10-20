//
//  StoreShippingViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 06/07/2023.
//

import Foundation
import Combine
import FirebaseFirestore

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
    
    @Published var showToast = false
    @Published var msg = ""
    
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
            store = try await storesDao.getStore(uId: storeId)!
            if var list = store?.listAreas  {
                self.list = list.uniqueElements()
            }
        } catch {
            print(error.localizedDescription)
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
            
            showToast("Store Shipping info changed")
            DispatchQueue.main.async {
                self.shouldDismissView = true
            }
        } catch {
            showToast(error.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func showToast(_ msg: String) {
        self.msg = msg
        showToast.toggle()
    }
}
