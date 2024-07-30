//
//  EmployeeAccessLevel.swift
//  Vondera
//
//  Created by Shreif El Sayed on 12/07/2024.
//

import SwiftUI



struct EmployeeAccessLevel: View {
    @Binding var accessLevels:AccessLevels
    @Binding var currentRole:UserRoles
    @State private var searchText: String = ""
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Picker(selection: $currentRole) {
                    ForEach(UserRoles.allCases, id: \.self) { item in
                        Text(item.getDisplayName())
                            .tag(item)
                    }
                } label: {
                    Text("User Role")
                }
                .onChange(of: currentRole) { _ in
                    accessLevels = currentRole.getDefaultAccessLevel()
                    ToastManager.shared.showToast(msg: "Default access levels updated !")
                }
                
                Text(currentRole.getRoleDesc())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            
            if searchText.isEmpty || "Orders".localizedStandardContains(searchText) {
                Section(header: Text("Orders")) {
                    Toggle("Read", isOn: $accessLevels.orders.read)
                    Toggle("Write", isOn: $accessLevels.orders.write)
                    Toggle("Update", isOn: $accessLevels.orders.update)
                    Toggle("Delete", isOn: $accessLevels.orders.delete)
                }
            }
            
            if searchText.isEmpty || "Expenses".localizedStandardContains(searchText) {
                Section(header: Text("Expenses")) {
                    Toggle("Read", isOn: $accessLevels.expenses.read)
                    Toggle("Add", isOn: $accessLevels.expenses.add)
                    Toggle("Remove", isOn: $accessLevels.expenses.remove)
                    Toggle("Export", isOn: $accessLevels.expenses.export)
                }
            }
            
            if searchText.isEmpty || "Statistics".localizedStandardContains(searchText) {
                Section(header: Text("Statistics")) {
                    Toggle("Read", isOn: $accessLevels.statistics.read)
                    Toggle("Export", isOn: $accessLevels.statistics.export)
                }
            }
            
            if searchText.isEmpty || "Customers Data".localizedStandardContains(searchText) {
                Section(header: Text("Customers Data")) {
                    Toggle("Read", isOn: $accessLevels.customersData.read)
                    Toggle("Export", isOn: $accessLevels.customersData.export)
                }
            }
            
            if searchText.isEmpty || "Access Couriers".localizedStandardContains(searchText) {
                Section(header: Text("Access Couriers")) {
                    Toggle("Add", isOn: $accessLevels.accessCouriers.add)
                    Toggle("Assign", isOn: $accessLevels.accessCouriers.assign)
                    Toggle("Remove", isOn: $accessLevels.accessCouriers.remove)
                }
            }
            
            if searchText.isEmpty || "Warehouse".localizedStandardContains(searchText) {
                Section(header: Text("Warehouse")) {
                    Toggle("Read", isOn: $accessLevels.warehouse.read)
                    Toggle("Add", isOn: $accessLevels.warehouse.add)
                    Toggle("Export", isOn: $accessLevels.warehouse.export)
                }
            }
            
            if searchText.isEmpty || "Products".localizedStandardContains(searchText) {
                Section(header: Text("Products")) {
                    Toggle("Read", isOn: $accessLevels.products.read)
                    Toggle("Write", isOn: $accessLevels.products.write)
                    Toggle("Update", isOn: $accessLevels.products.update)
                    Toggle("Delete", isOn: $accessLevels.products.delete)
                }
            }
            
            if searchText.isEmpty || "Categories".localizedStandardContains(searchText) {
                Section(header: Text("Categories")) {
                    Toggle("Read", isOn: $accessLevels.categories.read)
                    Toggle("Write", isOn: $accessLevels.categories.write)
                    Toggle("Update", isOn: $accessLevels.categories.update)
                    Toggle("Delete", isOn: $accessLevels.categories.delete)
                }
            }
            
            if searchText.isEmpty || "Team Members".localizedStandardContains(searchText) {
                Section(header: Text("Team Members")) {
                    Toggle("Read", isOn: $accessLevels.teamMembers.read)
                    Toggle("Add", isOn: $accessLevels.teamMembers.add)
                    Toggle("Update", isOn: $accessLevels.teamMembers.update)
                    Toggle("Delete", isOn: $accessLevels.teamMembers.delete)
                }
            }
            
            if searchText.isEmpty || "VPay".localizedStandardContains(searchText) {
                Section(header: Text("VPay")) {
                    Toggle("Read", isOn: $accessLevels.vPay.read)
                    Toggle("Payouts", isOn: $accessLevels.vPay.payouts)
                }
            }
            
            if searchText.isEmpty || "Complaints".localizedStandardContains(searchText) {
                Section(header: Text("Complaints")) {
                    Toggle("Read", isOn: $accessLevels.complaints.read)
                    Toggle("Add", isOn: $accessLevels.complaints.add)
                    Toggle("Update", isOn: $accessLevels.complaints.update)
                }
            }
            
            if searchText.isEmpty || "Other".localizedStandardContains(searchText) {
                Section(header: Text("Other")) {
                    Toggle("Can subscribe to the store", isOn: $accessLevels.subscription)
                    Toggle("Can customize the website", isOn: $accessLevels.websiteCustomization)
                    Toggle("Can update store settings", isOn: $accessLevels.storeSettings)
                }
            }
        }
        .navigationBarTitle("Access Levels")
        .searchable(text: $searchText, prompt: "Search for access ...")
    }
}
