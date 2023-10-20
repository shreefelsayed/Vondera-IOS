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
    
    func saveUser(user:UserData?) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            defaults.set(encoded, forKey: key)
            return
        }
    }
    
    func getLocalUser() -> UserData? {
        if let savedPerson = defaults.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(UserData.self, from: savedPerson) {
               return loadedPerson
            }
        }
        
        return nil
    }
}
