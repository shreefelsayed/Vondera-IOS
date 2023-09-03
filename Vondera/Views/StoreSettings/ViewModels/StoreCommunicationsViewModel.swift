import Foundation
import Combine

class StoreCommunicationsViewModel : ObservableObject {
    var store:Store
    var storesDao = StoresDao()
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var showToast = false
    @Published var gov = ""
    @Published var msg = ""
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
            store.phone = phone
            store.address = address

            // Saving local
            var myUser = await LocalInfo().getLocalUser()
            if myUser!.storeId == store.ownerId {
                myUser!.store = self.store
                _ = await LocalInfo().saveUser(user: myUser!)
            }
            
            showTosat(msg: "Info updated")
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
