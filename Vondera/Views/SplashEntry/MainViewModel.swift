//
//  MainViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/06/2023.
//

import Foundation
import FirebaseAuth

class MainViewModel : ObservableObject {
    @Published var signed:Bool = false
    
    
    func getUserData() async {
        do {
            let success = try await AuthManger().getData()
            DispatchQueue.main.async {
                self.signed = success
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    init(){
        self.signed = Auth.auth().currentUser != nil
        
        Auth.auth().addStateDidChangeListener{ _, user in
            self.signed = user != nil
        }
    }
}
