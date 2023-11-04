//
//  CreateAccountViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import Combine

class CreateAccountViewModel: ObservableObject {
    var authInfo:AuthProviderInfo?
    
    @Published var email = ""
    @Published var gov:String = GovsUtil().govs.first!
    @Published var name = ""
    @Published var storeName = ""
    @Published var storeAddress = ""
    @Published var storeGov = ""
    @Published var password = ""
    @Published var currentPage = 1
    @Published var slogan = ""
    @Published var refferCode = ""
    
    
    @Published var selectedCateogry:Int? = 0
    @Published var selectedMarkets:[String] = []

    @Published var address = ""
    @Published var bPhone = ""
    @Published var phone = ""
    
    @Published var isSaving = false
    @Published var isCreated = false
    
    @Published var errorMsg:String?

    let authManger = AuthManger()
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    // Username
    @Published var validName = false
    @Published var validatingName = false
    @Published var userName = "" {
        didSet {
           // --> Validate it on chage
            Task {
                await validateUserName()
            }
        }
    }
    
    init(authInfo:AuthProviderInfo?) {
        self.authInfo = authInfo
    }
    
    
    func showPrevPage() {
        if currentPage == 1 {
            shouldDismissView = true
            return
        }
        
        currentPage -= 1
    }
    
    func showNextPage() async {
        if currentPage == 1 {
            if checkFirstPage() {
                currentPage += 1
            }
        } else if currentPage == 2 {
            if checkSecondPage() {
                await createAccount()
            }
        }
    }
    
    func validateUserName() async {
        validName = false
        validatingName = true
        
        if let valid = try? await StoresDao().validId(id: userName) {
            DispatchQueue.main.async {
                self.validName = valid
                self.validatingName = false
            }
        }
    }
    
    func createAccount() async {
        isSaving = true
        
        do {
            // --> Check if email already exists
            let emailExists = try await UsersDao().emailExists(email: email)
            guard !emailExists else {
                isSaving = false
                showError(err: "This email is already signed up")
                return
            }
            
            // --> Create user Object
            var user = UserData(id: "", name: name, email: email, phone: phone, addedBy: refferCode, accountType: "Owner", pass: password)
            
            if let authInfo = authInfo {
                user.userURL = authInfo.url
                user.facebookId = authInfo.provider == "facebook" ? authInfo.id : ""
                user.appleId = authInfo.provider == "apple" ? authInfo.id : ""
                user.googleId = authInfo.provider == "google" ? authInfo.id : ""
            }
            
            // --> Create Store Object
            let store = Store(name: storeName, address: address, governorate: gov, phone: bPhone, subscribedPlan: SubscribedPlan(), ownerId: "")
            
            store.almostOut = 5
            store.merchantId = userName.replacingOccurrences(of: " ", with: "").lowercased()
            store.categoryNo = selectedCateogry
            store.listMarkets = selectedMarkets.map { id in
                return StoreMarketPlace(id: id, active: true)
            }
            
            // --> Create a store account
            let accountCreated = await AuthManger().createStoreOwnerUser(userData: &user, store: store)
            
            if accountCreated == false {
                showError(err: "Something wrong happened")
                isSaving = false
                return
            }
            
            if let authInfo = authInfo {
                _ = await AuthManger().connectToCred(cred: authInfo.cred)
            }
            
            
            isCreated = accountCreated
            isSaving = false
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                self.isCreated = false
                Task {
                    try! await AuthManger().getData()
                }
                self.shouldDismissView = true
            }
        } catch {
            showError(err: error.localizedDescription)
        }
    }
    
    func checkSecondPage() -> Bool {
        guard storeName.isValidName else {
            showError(err: "Enter a valid store name")
            return false
        }
        
        guard validName, userName.count > 2 else {
            showError(err: "Enter your site username")
            return false
        }
        
        guard bPhone.isPhoneNumber else {
            showError(err: "Enter a valid bussiness phone number")
            return false
        }
        
        guard !gov.isBlank else {
            showError(err: "Select your government")
            return false
        }
        
        guard !address.isBlank else {
            showError(err: "Enter your address")
            return false
        }
        
        return true
    }
    
    func checkFirstPage() -> Bool {
        guard name.isValidName else {
            showError(err: "Enter your name")
            return false
        }
        
        /*guard phone.isPhoneNumber else {
            showError(err: "Enter a valid phone number")
            return false
        }*/
        
        guard email.isValidEmail else {
            showError(err: "Enter a valid email")
            return false
        }
        
        guard password.isValidPassword else {
            showError(err: "Enter a valid password")
            return false
        }
        
        return true
    }
    
    func showError(err:String) {
        DispatchQueue.main.async {
            self.errorMsg = err
        }
    }
}
