//
//  LoginViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMsg = ""
    @Published var showToast = false
    @Published var isShowingSheet = false
    @Published var sheetType = "" //Login - SignUp - Email Login
    @Published var currentSlide = 0
    let authManger:AuthManger
    
    init() {
        authManger = AuthManger()
    }
    
    func hideSheet() {
        isShowingSheet = false
        sheetType = ""
    }
    
    func showEmailSheet() {
        isShowingSheet = true
        sheetType = "Email Login"
    }
    
    func showSignUpSheet() {
        isShowingSheet = true
        sheetType = "SignUp"
    }
    
    func showLoginSheet() {
        isShowingSheet = true
        sheetType = "Login"
    }
    
    func googleSignIn() async -> Bool {
        return await authManger.signUserWithGoogle()
    }
    
    func login() async -> Bool {
        guard validate() else {
            return false
        }
        
        let loggedIn = await authManger.signUserInViaMail(email: email, password: password)
        
        if loggedIn == false {
            errorMsg = "No user was found"
            showToast.toggle()
            return false
        }
        
        return true
    }
    
    func loginWithFacebook() async {
        
    }
    
    func validate() -> Bool {
        errorMsg = ""
        showToast = false
        
        guard !email.isBlank, !password.isBlank else {
            errorMsg = "Please fill in all fields"
            showToast.toggle()
            return false
        }
        
        guard email.isValidEmail else {
            errorMsg = "Please enter valid email"
            showToast.toggle()
            return false
        }
        
        guard password.count > 5 else {
            errorMsg = "Please enter valid password"
            showToast.toggle()
            return false
        }
        
        return true
    }
}
