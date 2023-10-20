//
//  NewCourierViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 28/06/2023.
//

import Foundation
import Combine

class NewCourierViewModel : ObservableObject {
    var storeId:String
    var couriersDao:CouriersDao
   
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

    
    @Published var showToast = false
    @Published var msg = ""
    @Published var isSaving = false
    
    
    init(storeId:String) {
        self.storeId = storeId
        couriersDao = CouriersDao(storeId: storeId)
    }
    
    func save() async {
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
            
            try await couriersDao.addCourier(courier: &courier)
            
            // --> Saving Local
            let myUser = UserInformation.shared.getUser()
            if myUser?.storeId == storeId {
                if var couriersCount = myUser?.store?.couriersCount {
                    couriersCount = couriersCount + 1
                    myUser?.store?.couriersCount = couriersCount
                    UserInformation.shared.updateUser(myUser)
                }
            }
            
            showTosat(msg: "Courier Added")
            
            // Dispatch UI updates on the main thread
            DispatchQueue.main.async { [courier] in
                self.newItem = courier
                self.shouldDismissView = true
                self.isSaving = false
            }
        } catch {
            print("error happened \(error.localizedDescription)")
            
            // Dispatch UI updates on the main thread
            DispatchQueue.main.async {
                self.showTosat(msg: error.localizedDescription)
                self.isSaving = false
            }
        }
    }
    
    func showTosat(msg: String) {
        DispatchQueue.main.async {
            self.msg = msg
            self.showToast.toggle()
        }
    }
}

