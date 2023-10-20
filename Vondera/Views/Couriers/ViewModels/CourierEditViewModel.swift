//
//  CourierEditViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import Foundation
import Combine

class CourierEditViewModel : ObservableObject {
    var id:String
    var storeId:String

    var couriersDao:CouriersDao
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var name = ""
    @Published var phone = ""
    @Published var active:Bool = false
    
    @Published var isSaving = false
    @Published var isLoading = false
    
    @Published var msg:String?
    
    init(id:String, storeId:String) {
        self.id = id
        self.storeId = storeId
        
        couriersDao = CouriersDao(storeId: storeId)
        
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
            let courier = try await couriersDao.getCourier(id: id)
            name = courier.name
            phone = courier.phone
            active = courier.visible
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func update() async {
        guard !name.isBlank else {
            showToast("Fill the Courier name")
            return
        }
        
        guard phone.isPhoneNumber else {
            showToast("Fill the Courier phone")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:Any] = ["name": name,
                                    "phone": phone,
                                    "visible":active]
            
            try await couriersDao.update(id: id, hashMap: map)
            
            showToast("Courier info changed")
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
    }
}

