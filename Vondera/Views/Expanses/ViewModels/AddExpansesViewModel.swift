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
    var storeId:String
    var myUser:UserData?
    var expansesDao:ExpansesDao
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    @Published var newItem:Expense?

    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    @Published var price = 0
    @Published var desc = ""
    
    @Published var msg:LocalizedStringKey?
    @Published var isSaving = false
    
    
    init(storeId:String) {
        self.storeId = storeId
        expansesDao = ExpansesDao(storeId: storeId)
        
        Task {
            myUser = UserInformation.shared.getUser()
        }
    }
    
    func save() async {
        guard price > 0 else {
            showTosat(msg: "Enter a valid amount")
            return
        }
        
        guard !desc.isBlank else {
            showTosat(msg: "Add a description for your expanse")
            return
        }
        
        
        DispatchQueue.main.async {
            self.isSaving = true
        }
        
        do {
            // --> Update the database
            var expanses = Expense(amount: price, description: desc, madeBy: myUser?.id ?? "")
            try await expansesDao.create(expanses: &expanses)
            
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
