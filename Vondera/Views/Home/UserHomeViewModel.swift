//
//  UserHomeViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import Foundation

class UserHomeViewModel : ObservableObject {
    var usersDao = UsersDao()
    @Published var myUser:UserData?
    
    init() {
        Task {
            await getUser()
        }
    }
    
    func getUser() async {
        let user = UserInformation.shared.getUser()
        
        if user == nil {
            await AuthManger().logOut()
        }
        
        DispatchQueue.main.async {
            self.myUser = user
        }
    }
    
    func userOnline() async {
        do {
            try await usersDao.update(id: myUser!.id, hash: ["online": true])
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func userOffline() async {
        do {
            try await usersDao.update(id: myUser!.id, hash: ["online": false])
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
}
