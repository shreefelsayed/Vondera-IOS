import Foundation
import Combine
import SwiftUI

class StoreCommunicationsViewModel : ObservableObject {
    var store:Store
    var storesDao = StoresDao()
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var gov = ""
    @Published var msg:LocalizedStringKey?
    @Published var phone = ""
    @Published var address = ""

    @Published var isSaving = false
    
    
    init(store:Store) {
        self.store = store
        self.phone = store.phone
        self.address = store.address
        self.gov = store.governorate
    }
    
    func updateName() async {
        guard phone.isPhoneNumber || !address.isBlank else {
            showTosat(msg: "Fill all the data")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            try await storesDao.update(id: store.ownerId, hashMap: ["phone": phone, "address":address, "governorate": gov])

            // Saving local
            if let myUser = UserInformation.shared.getUser() {
                myUser.store?.phone = phone
                myUser.store?.address = address

                UserInformation.shared.updateUser(myUser)
            }
            
            showTosat(msg: "Info updated")
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
