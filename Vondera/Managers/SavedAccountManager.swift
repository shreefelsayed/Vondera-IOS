//
//  SavedAccountManager.swift
//  Vondera
//
//  Created by Shreif El Sayed on 17/10/2023.
//

import Foundation

class SavedAccountManager {
    let KEY = "accounts"
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func getAllUsers() -> [LoginInfo] {
        if let encodedData = UserDefaults.standard.data(forKey: KEY) {
            if let savedItemsList = try? decoder.decode([LoginInfo].self, from: encodedData) {
                return savedItemsList
            }
        }
        
        return []
    }
    
    private func saveUsers(listCart: [LoginInfo]) {
        if let encodedData = try? encoder.encode(listCart) {
            UserDefaults.standard.set(encodedData, forKey: KEY)
        }
    }

    func addUser(userData:UserData) {
        addUser(savedItems: LoginInfo(id: userData.id, name: userData.name, email: userData.email, password: userData.pass, url: userData.userURL, accountType: userData.accountType, storeName: userData.store?.name ?? ""))
    }
    
    private func addUser(savedItems: LoginInfo) {
        var listItems = getAllUsers()
        
        // Check if it's already exists
        for (index, item) in listItems.enumerated() {
            if item.id == savedItems.id {
                listItems.remove(at: index)
            }
        }
        
        // Add the new users
        listItems.append(savedItems)
        saveUsers(listCart: listItems)
    }
    
    func removeUser(uId:String) {
        var listItems = getAllUsers()
        // Check if it's exists
        for (index, item) in listItems.enumerated() {
            if item.id == uId {
                listItems.remove(at: index)
            }
        }
        saveUsers(listCart: listItems)
    }
    
}
