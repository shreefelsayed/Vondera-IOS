//
//  EmployeeSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 03/07/2023.
//

import SwiftUI
import AlertToast

struct EmployeeSettings: View {
    var id:String
    @ObservedObject var viewModel:EmployeeSettingsViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(id: String) {
        self.id = id
        self.viewModel = EmployeeSettingsViewModel(id: id)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Employee name", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                
                TextField("Phone Number", text: $viewModel.phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                
                if viewModel.selectedAccountType == .sales {
                    TextField("Commission", text: Binding(
                        get: { String(viewModel.perc) },
                        set: { if let newValue = Double($0) { viewModel.perc = newValue } }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                }
                

                if viewModel.myUser != nil {
                    VStack(alignment: .leading) {
                        Picker("Account Type", selection: $viewModel.selectedAccountType) {
                            Text("Admin").tag(AccountType.admin)
                            Text("Employee").tag(AccountType.employee)
                            Text("Sales Account").tag(AccountType.sales)
                        }
                        .pickerStyle(.segmented)
                        Text(desc)
                            .font(.caption)
                    }
                    .isHidden(viewModel.myUser!.accountType != "Owner" && viewModel.myUser!.accountType != "Store Admin")
                    
                }
                
                
                Toggle("Account Active", isOn: $viewModel.active)
                    .isHidden(viewModel.myUser!.accountType != "Owner" && viewModel.myUser!.accountType != "Store Admin")
                
                VStack(alignment: .leading) {
                    Text("Email address")
                        .bold()
                    
                    Text(viewModel.email)
                    
                    Text("Password")
                        .bold()
                    
                    Text(viewModel.pass)
                }.isHidden(viewModel.myUser!.accountType != "Store Admin" && viewModel.myUser!.accountType != "Owner")
                
            }
            .isHidden(viewModel.isLoading)
            
        }.padding()
            .navigationTitle("Edit Employee")
            .overlay(alignment: .center, content: {
                ProgressView()
                    .isHidden(!viewModel.isLoading)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        update()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .willProgress(saving: viewModel.isSaving)
            .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
                if shouldDismiss {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            .toast(isPresenting: $viewModel.showToast){
                AlertToast(displayMode: .banner(.slide),
                           type: .regular,
                           title: viewModel.msg)
            }
    }
    
    func update() {
        Task {
            await viewModel.update()
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

struct EmployeeSettings_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeSettings(id: "")
    }
}
