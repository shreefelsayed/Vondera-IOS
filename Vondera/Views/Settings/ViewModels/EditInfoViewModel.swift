//
//  EditInfoViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation
import AlertToast
import Combine


class EditInfoViewModel : ObservableObject {
    var user:UserData
    var usersDao = UsersDao()
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var showToast = false
    @Published var msg = ""
    @Published var name = ""
    @Published var isSaving = false
    
    
    init(user:UserData) {
        self.user = user
        self.name = user.name
    }
    
    func updateName() async {
        guard !name.isBlank else {
            showTosat(msg: "Fill your name")
            return
        }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            try await usersDao.update(id: user.id, hash: ["name": name])
            user.name = name
            let _ = await LocalInfo().saveUser(user: user)
            showTosat(msg: "Name Changed")
            
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
