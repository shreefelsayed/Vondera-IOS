//
//  ChangePasswordViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//


import Foundation
import AlertToast
import Combine


class ChangePasswordViewModel : ObservableObject {
    var user:UserData
    var usersDao = UsersDao()
    var isSaving = false
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var showToast = false
    @Published var msg = ""
    @Published var pass1 = ""
    @Published var pass2 = ""
    @Published var oldPass = ""

    init(user:UserData) {
        self.user = user
    }
    
    func check() -> Bool {
        guard pass1.isValidPassword else {
            self.isSaving = false
            showTosat(msg: "Enter a valid password")
            return false
        }
        
        guard pass2.isValidPassword else {
            self.isSaving = false
            showTosat(msg: "Enter a valid password")
            return false
        }
        
        guard pass1 == pass2 else {
            self.isSaving = false
            showTosat(msg: "Passwords don't match")
            return false
        }
        
        guard oldPass == user.pass else {
            self.isSaving = false
            showTosat(msg: "Old password isn't correct")
            return false
        }
        
        return true
    }
    
    func updatePassword() async {
        guard check() else {
            return
        }
                
        do {
            // --> Update the database
            let saved = try await AuthManger().changePassword(newPass: pass1, user: user)
            guard saved else {
                showTosat(msg: "Error happened")
                return
            }
            
            try await usersDao.update(id: user.id, hash: ["pass": pass1])
            user.pass = pass1
            UserInformation.shared.updateUser(user)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showTosat(msg: "Password Changed")
                self.shouldDismissView = true
            }
            
        } catch {
            showTosat(msg: error.localizedDescription)
        }
    }
    
    func showTosat(msg: String) {
        self.msg = msg
        showToast.toggle()
        self.isSaving = false
    }
}
