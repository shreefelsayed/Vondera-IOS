//
//  EmployeeSettingsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import Foundation
import Combine
import SwiftUI

class EmployeeSettingsViewModel : ObservableObject {
    @Published var id:String
    var usersDao = UsersDao()
    var myUser = UserInformation.shared.getUser()
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var name = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var pass = ""
    @Published var selectedAccountType = UserRoles.admin
    @Published var perc:Double = 0
    @Published var active:Bool = false
    
    @Published var isSaving = false
    @Published var isLoading = false
    
    @Published var msg:LocalizedStringKey?
    
    init(id:String) {
        self.id = id
        
        // --> Set the published values
        Task {
            self.myUser = UserInformation.shared.getUser()
            await getData()
        }
    }
    
    func getData() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let editUser = try await usersDao.getUser(uId: id).item!
            name = editUser.name
            phone = editUser.phone
            email = editUser.email
            pass = editUser.pass
            selectedAccountType = UserRoles(rawValue: editUser.accountType) ?? UserRoles.admin
            perc = Double((editUser.percentage ?? 0) * 100)
            active = editUser.active
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func update() async {
        guard !name.isBlank else {
            showToast("Fill the Employee name")
            return
        }
        
        guard phone.isPhoneNumber else {
            showToast("Fill the Employee phone")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            let map:[String:Any] = ["name": name,
                                    "phone": phone,
                                    "accountType": selectedAccountType.rawValue,
                                    "perc": (perc / 100),
                                    "active":active]
            
            try await usersDao.update(id: id, hash: map)
            
            showToast("Employee info changed")
            DispatchQueue.main.async {
                self.shouldDismissView = true
            }
        } catch {
            showToast(error.localizedDescription.localize())
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func showToast(_ msg: LocalizedStringKey) {
        self.msg = msg
    }
}
