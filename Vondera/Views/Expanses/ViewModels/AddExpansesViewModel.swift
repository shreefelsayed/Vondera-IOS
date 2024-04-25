//
//  AddExpansesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 29/06/2023.
//

import Foundation
import Combine
import SwiftUI

class AddExpansesViewModel : ObservableObject {
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    @Published var newItem:Expense?

    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var price = 0.0
    @Published var desc = ""
    
    @Published var msg:LocalizedStringKey?
    @Published var isSaving = false
    

    
    func save() async {
        guard price > 0 else {
            showTosat(msg: "Enter a valid amount")
            return
        }
        
        guard !desc.isBlank else {
            showTosat(msg: "Add a description for your expanse")
            return
        }
        
        guard let user = UserInformation.shared.user else {
                    return
                }
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            var expanses = Expense(amount: price, description: desc, madeBy: user.id)
            try await ExpansesDao(storeId: user.storeId).create(expanses: &expanses)
            
            DispatchQueue.main.async { [expanses] in
                //self.showTosat(msg: "Expanse Added")
                self.newItem = expanses
                self.shouldDismissView = true
            }
        } catch {
            //showTosat(msg: error.localizedDescription)
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = false
        }
        
    }
    
    func showTosat(msg: LocalizedStringKey) {
        DispatchQueue.main.async {
            self.msg = msg
        }
    }
}
