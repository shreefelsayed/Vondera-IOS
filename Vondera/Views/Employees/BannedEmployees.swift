//
//  BannedEmployees.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/03/2024.
//

import SwiftUI

struct BannedEmployees: View {
    
    @State private var items = [UserData]()
    @State private var isLoading = false
    @State private var searchText = ""
    
    var body: some View {
        List {
            SkeltonManager(isLoading: isLoading, count: 6, skeltonView: EmployeeCardSkelton())
            
            ForEach($items.indices, id: \.self) { index in
                if $items[index].wrappedValue.filter(searchText) {
                    EmployeeCard(user: items[index])
                }
            }
        }
        .searchable(text: $searchText, prompt: Text("Search \($items.count) Employees"))
        .refreshable {
            await getData()
        }
        .task {
            await getData()
        }
        .withEmptyView(image: .bannedUsers, text: "No team members are banned", count: items.count, loading: isLoading)
        .withEmptySearchView(searchText: searchText, resultCount: items.filter({ $0.filter(searchText)}).count)
        .navigationTitle("Banned Members")
    }
    
    private func getData() async {
        if let storeId = UserInformation.shared.user?.storeId {
            if let result = try? await UsersDao().storeEmployees(expect: "", storeId: storeId, active: false) {
                
                DispatchQueue.main.async {
                    self.items = result
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    BannedEmployees()
}
