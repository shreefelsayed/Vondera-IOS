//
//  NewEmployeeViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import Firebase

enum AccountType: String {
    case owner = "Owner"
    case admin = "Store Admin"
    case employee = "Worker"
    case sales = "Marketing"
    
    static func fromValue(_ value: String) -> AccountType? {
        for case let accountType in AccountType.allValues {
            if accountType.rawValue == value {
                return accountType
            }
        }
        return nil
    }
    
    static var allValues: [AccountType] {
        return [.admin, .employee, .sales]
    }
}

class NewEmployeeViewModel : ObservableObject {
    var storeId:String
    var myUser:UserData?
    var usersDao:UsersDao
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    @Published var newItem:UserData?
    
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var name = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var pass = ""
    @Published var selectedAccountType = AccountType.admin
    @Published var perc:Double = 0
    
    @Published var showToast = false
    @Published var msg = ""
    @Published var isSaving = false
    
    
    init(storeId:String) {
        self.storeId = storeId
        usersDao = UsersDao()
        
        Task {
            myUser = await LocalInfo().getLocalUser()
        }
    }
    
    func save() async {
        guard email.isValidEmail else {
            showTosat(msg: "Enter a valid employee email")
            return
        }
        
        guard pass.isValidPassword else {
            showTosat(msg: "Enter a valid password")
            return
        }
        
        guard !name.isBlank else {
            showTosat(msg: "Fill the Employee name")
            return
        }
        
        guard phone.isPhoneNumber else {
            showTosat(msg: "Fill the Employee phone")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            //let firebaseOptions = createFirebaseOptions()
            //FirebaseCore.FirebaseApp.configure(name: "Vonderaa", options: firebaseOptions)
            
            //var mAuth2 = Auth.auth(app: FirebaseApp.app(name: "Vonderaa")!)
            
            var fbUser = try await Auth.auth().createUser(withEmail: email, password: pass)
            
            // --> Update the database
            var userData = UserData(id: fbUser.user.uid, name: name, email: email, phone: phone, addedBy: myUser?.id ?? "", accountType: selectedAccountType.rawValue, pass: pass)
            
            userData.storeId = storeId
            userData.percentage = perc
            
            
            try await Auth.auth().signIn(withEmail: myUser!.email, password: myUser!.pass)
            
            try await usersDao.addUser(user: userData)
            
            // --> Saving Local
            var myUser = await LocalInfo().getLocalUser()
            if myUser?.storeId == storeId {
                if var employeesCount = myUser?.store?.employeesCount {
                    employeesCount = employeesCount + 1
                    myUser?.store?.employeesCount = employeesCount
                    _ = await LocalInfo().saveUser(user: myUser!)
                }
            }
            
            showTosat(msg: "Employee Added")
            DispatchQueue.main.async { [userData] in
                self.newItem = userData
                self.shouldDismissView = true
            }
        } catch {
            showTosat(msg: error.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func createFirebaseOptions() -> FirebaseOptions {
        let firebaseOptions = FirebaseOptions.defaultOptions()
        firebaseOptions!.databaseURL = "brands-61c3d-default-rtdb"
        firebaseOptions!.apiKey = "AIzaSyC3Af2bq7ufCuC38UjHxBwsWUkCoKjjUZw"
        firebaseOptions!.googleAppID = "1:473830923339:android:02c4c0e62ca2c67db141ce"
        
        return firebaseOptions!
    }
    
    
    func showTosat(msg: String) {
        self.msg = msg
        showToast.toggle()
    }
}

