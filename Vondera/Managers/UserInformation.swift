//
//  UserInformation.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/10/2023.
//

import Foundation

class UserInformation : ObservableObject {
    @Published var user:UserData?
    static let shared = UserInformation()
    
    init(){}
    
    func updateUser(_ user:UserData?) {
        if let user = user {
            self.user = user
            LocalInfo().saveUser(user: user)
        }
    }
    
    func getUser() -> UserData? {
        if let user = user {
            return user
        } else if let localUser = LocalInfo().getLocalUser() {
            self.user = localUser
            return user
        }
        
        return nil
    }
    
    func clearUser() {
        user = nil
        LocalInfo().saveUser(user: nil)
    }
}
