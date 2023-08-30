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
    @Binding var currentList:[UserData]
    @Environment(\.presentationMode) private var presentationMode
    
    init(storeId: String, currentList: Binding<[UserData]>) {
        self.storeId = storeId
        self._currentList = currentList
        self.viewModel = NewEmployeeViewModel(storeId: storeId)
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Employee name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                
                TextField("Phone Number", text: $viewModel.phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                
                SecureField("Password", text: $viewModel.pass)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                if viewModel.selectedAccountType == .sales {
                    TextField("Commission", text: Binding(
                        get: { String(viewModel.perc) },
                        set: { if let newValue = Double($0) { viewModel.perc = newValue } }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                }
                
                Picker("Account Type", selection: $viewModel.selectedAccountType) {
                        Text("Admin").tag(AccountType.admin)
                        Text("Employee").tag(AccountType.employee)
                        Text("Sales Account").tag(AccountType.sales)
                }
                .pickerStyle(.segmented)
                
                Text(desc)
                    .font(.caption)
            }
        }
        .padding()
        .navigationTitle("Create Employee")
        .willProgress(saving: viewModel.isSaving)
        .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                if viewModel.newItem != nil {
                    currentList.append(viewModel.newItem!)
                }
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $viewModel.showToast){
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

