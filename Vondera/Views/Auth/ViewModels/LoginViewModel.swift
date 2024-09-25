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
    
    let authManger:AuthManger
    
    init() {
        authManger = AuthManger()
    }
    
    func appleSignIn(cred:AuthCredential, id: String) async -> Bool {
        return await authManger.signUserWithApple(authCred: cred, appleId: id)
    }
    
    func fbSignIn(cred:AuthCredential, id: String) async -> Bool {
        return await authManger.signInWithFacebook(authCred: cred, fbId: id)
    }
    
    func googleSignIn(cred:AuthCredential, id: String) async -> Bool {
        return await authManger.signUserWithGoogle(authCred: cred, id: id)
    }
    
    func login() async -> Bool {
        guard validate() else {
            return false
        }
        
        let loggedIn = await authManger.signUserInViaMail(email: email.trimming(spaces: .leadingAndTrailing),
                                                          password: password.trimming(spaces: .leadingAndTrailing))
        
        if loggedIn == false {
            ToastManager.shared.showToast(msg: "No user was found", toastType: .error)
            return false
        }
        
        return true
    }
    
    func loginWithFacebook() async {
        
    }
    
    func validate() -> Bool {        
        guard !email.isBlank, !password.isBlank else {
            ToastManager.shared.showToast(msg: "Please fill in all fields", toastType: .error)
            return false
        }
        
        guard email.isValidEmail else {
            ToastManager.shared.showToast(msg: "Please enter valid email", toastType: .error)
            return false
        }
        
        guard password.count > 5 else {
            ToastManager.shared.showToast(msg: "Please enter valid password", toastType: .error)
            return false
        }
        
        return true
    }
}
