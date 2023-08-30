//
//  CreateAccountViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation

class CreateAccountViewModel: ObservableObject {
    @Published var email = ""
    @Published var name = ""
    @Published var storeName = ""
    @Published var storeAddress = ""
    @Published var storeGov = ""
    @Published var password = ""
    @Published var errorMsg = ""
    @Published var currentPage = 1
    @Published var slogan = ""
    @Published var refferCode = ""

    @Published var address = ""
    @Published var bPhone = ""
    @Published var phone = ""
    @Published var showToast = false
    
    let authManger:AuthManger
    
    init() {
        authManger = AuthManger()
    }
    
    func showNextPage() async {
        if currentPage == 1 {
            if checkFirstPage() {
                currentPage = currentPage + 1
            }
        } else if currentPage == 2 {
            if checkSecondPage() {
                await createAccount()
            }
        }
    }
    
    func createAccount() async {
        // --> Create user Object
        var user = UserData(id: "", name: name, email: email, phone: phone, addedBy: refferCode, accountType: "Owner", pass: password)
        
        // --> Create Store Object
        let store = Store(name: storeName, address: address, governorate: "", phone: bPhone, subscribedPlan: SubscribedPlan(), ownerId: "")
        
        // --> Create a store account
        let accountCreated = await AuthManger().createStoreOwnerUser(userData: &user, store: store)
        
        if accountCreated == false {
            showError(err: "Something wrong happened")
        } else {
            print("Account has been created")
            
            // TODO : Navigate to home screen
        
        }
        
        
    }
    
    func checkSecondPage() -> Bool {
        guard !storeName.isBlank else {
            showError(err: "Enter your store name")
            return false
        }
        
        guard bPhone.isPhoneNumber else {
            showError(err: "Enter a valid bussiness phone number")
            return false
        }
        
        guard !address.isBlank else {
            showError(err: "Enter your address")
            return false
        }
        
        return true
    }
    
    func checkFirstPage() -> Bool {
        guard !name.isBlank else {
            showError(err: "Enter your name")
            return false
        }
        
        guard phone.isPhoneNumber else {
            showError(err: "Enter a valid phone number")
            return false
        }
        
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
        errorMsg = err
        showToast = true
    }
}
