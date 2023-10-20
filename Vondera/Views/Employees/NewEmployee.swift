//
//  NewEmployee.swift
//  Vondera
//
//  Created by Shreif El Sayed on 27/06/2023.
//

import SwiftUI
import AlertToast

struct NewEmployee: View {
    var storeId:String
    @ObservedObject var viewModel:NewEmployeeViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String) {
        self.storeId = storeId
        self.viewModel = NewEmployeeViewModel(storeId: storeId)
    }
    
    var body: some View {
        List {
            Section("User Info") {
                FloatingTextField(title: "Name", text: $viewModel.name, caption: "The name of the emloyee you want to add", required: true, autoCapitalize: .words)

                
                FloatingTextField(title: "Phone Number", text: $viewModel.phone, caption: "Use the whatsapp number of the employee", required: true, keyboard: .phonePad)
            }
            
            Section("Auth Credntials") {
                FloatingTextField(title: "Email Address", text: $viewModel.email, required: true, autoCapitalize: .never, keyboard: .emailAddress)
                
                FloatingTextField(title: "Password", text: $viewModel.pass, required: true, secure: true)
                
            }
            
            Section("Access") {
                Picker("Account Type", selection: $viewModel.selectedAccountType) {
                        Text("Admin").tag(AccountType.admin)
                        Text("Employee").tag(AccountType.employee)
                        Text("Sales Account").tag(AccountType.sales)
                }
                .pickerStyle(.menu)
                
                
                Text(desc)
                    .font(.caption)
                
                if viewModel.selectedAccountType == .sales {
                    HStack {
                        FloatingTextField(title: "Commission", text: .constant(""), caption: "This commission will be calculate from the order's netprofit From 1% to 99%", required: false, isNumric: true, number: $viewModel.perc)
                        
                        Text("%")
                    }
                }
            }
        }
        .navigationTitle("Create Employee")
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: Binding(value: $viewModel.msg)){
            AlertToast(displayMode: .banner(.slide),
                       type: .regular,
                       title: viewModel.msg)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    Task {
                        await viewModel.save()
                    }
                }
            }
        }
    }
    
    var desc:String {
        if viewModel.selectedAccountType == AccountType.admin {
            return "Admin account has access to the dashboard, add employees and couriers and the statics or reports"
        } else if viewModel.selectedAccountType == AccountType.employee {
            return "Employee account can add orders and make actions on the orders, can assign orders to couriers too"
        } else {
            return "Sales account can only add orders, search for orders. and you can add a sales commission based on the net profit of each order the account adds."
        }
    }
}

#Preview {
    NavigationStack {
        NewEmployee(storeId: Store.Qotoofs())
    }
}

