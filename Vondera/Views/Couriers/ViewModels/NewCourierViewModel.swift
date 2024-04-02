//
//  NewCourierViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2023.
//

import Foundation
import Combine
import SwiftUI

class NewCourierViewModel : ObservableObject {
    @Published var newItem:Courier?
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var name = ""
    @Published var phone = ""
    @Published var items = GovsUtil().getDefaultCourierList()

    @Published var msg:LocalizedStringKey?
    @Published var isSaving = false
    
    
    init() {
        setDefaultPrices()
    }
    
    func setDefaultPrices() {
        if let prices = UserInformation.shared.user?.store?.listAreas {
            for i in items.indices {
                let area = items[i]
                
                if let priceIndex = prices.firstIndex(where: { storeArea in storeArea.govName == area.govName }) {
                    items[i].price = prices[priceIndex].price
                }
            }
        }
    }
    
    func save() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        guard !name.isBlank else {
            showTosat(msg: "Fill the courier name")
            return
        }
        
        guard !phone.isBlank else {
            showTosat(msg: "Fill the courier phone")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            var courier = Courier(id: "", name: name, phone: phone, storeId: storeId)
            courier.listPrices = items.uniqueElements()
            
            try await CouriersDao(storeId: storeId).addCourier(courier: &courier)
            
            // --> Saving Local
            let myUser = UserInformation.shared.getUser()
            if myUser?.storeId == storeId {
                if var couriersCount = myUser?.store?.couriersCount {
                    couriersCount = couriersCount + 1
                    myUser?.store?.couriersCount = couriersCount
                    UserInformation.shared.updateUser(myUser)
                }
            }
            
            // Dispatch UI updates on the main thread
            DispatchQueue.main.async { [courier] in
                self.showTosat(msg: "Courier Added")
                self.newItem = courier
                self.shouldDismissView = true
                self.isSaving = false
            }
        } catch {            
            // Dispatch UI updates on the main thread
            DispatchQueue.main.async {
                self.showTosat(msg: error.localizedDescription.localize())
                self.isSaving = false
            }
        }
    }
    
    func showTosat(msg: LocalizedStringKey) {
        DispatchQueue.main.async {
            self.msg = msg
        }
    }
}

