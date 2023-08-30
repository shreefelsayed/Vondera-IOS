//
//  StoreSettingsViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import Foundation

class StoreSettingsViewModel : ObservableObject {
    @Published var user:UserData? = nil
    
    init() {
        Task {
            await initalize()
        }
        
    }
    
    func initalize() async  {
        let localUser = await LocalInfo().getLocalUser()!
        
        DispatchQueue.main.async {
            self.user = localUser
        }
    }
}
