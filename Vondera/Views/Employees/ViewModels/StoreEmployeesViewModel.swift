//
//  StoreEmployeesViewModel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 23/06/2023.
//

import Foundation

class StoreEmployeesViewModel: ObservableObject {
    @Published var items = [UserData]()
    @Published var searchText = ""

    @Published var isLoading = false
    @Published var error = ""
    
    init() {
        Task {
            await getData()
        }
    }
        
    func getData() async {
        guard !isLoading else {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        

        do {
            if let user = UserInformation.shared.user {
                var data = try await UsersDao().storeEmployees(expect: user.id, storeId: user.storeId, active: true)
                data = data.filter({ $0.accountType != "Owner" })
                DispatchQueue.main.async { [data] in
                    self.items = data
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}

