//
//  LocalInfo.swift
//  Vondera
//
//  Created by Shreif El Sayed on 19/06/2023.
//

import Foundation

class LocalInfo {
    let key:String = "LocalUser"
    let defaults = UserDefaults.standard
    
    func saveUser(user:UserData?) async -> Bool {        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            defaults.set(encoded, forKey: key)
            print("User saved")
            return true
        }
        
        return false
    }
    
    func getLocalUser() async -> UserData? {
        if let savedPerson = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(UserData.self, from: savedPerson) {
                print("User Founded")
               return loadedPerson
            }
        }
        
        return nil
    }
}
