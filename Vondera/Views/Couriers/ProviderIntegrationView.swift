//
//  ProviderIntegrationView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 24/02/2024.
//

import SwiftUI
import AlertToast

struct ProviderIntegrationView: View {
    var courierId:String
    
    @State  var saving = false
    @State  var loading = false
    @State  var selectedProvider = "None"
    
    @State  var requiredValues:[String:String] = [:]
    @State  var userInputs:[String] = []
    
    var myUser = UserInformation.shared.user
    var providers:[String] = ["None", "QBEXPRESS", "BOOSTA"]
    
    @State  var option1 = false
    @State  var option2 = false
    @State  var option3 = false
    @State  var apiData:[String:String] = [:]
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        List {
            // MARK : Use should choose the provider
            Picker("Choose Provider", selection: $selectedProvider) {
                ForEach(providers, id: \.self) { provider in
                    Text(provider)
                        .tag(provider)
                }
            }
            .onChange(of: selectedProvider) { newValue in
                updateRequiredValues()
            }
            
            if selectedProvider != "None" {
                // MARK: - Integration Info
                Section("Integration info") {
                    ForEach(Array(requiredValues.keys.enumerated()), id: \.element) { index, key in
                        FloatingTextField(title: "\(requiredValues[key] ?? "")", text: $userInputs[index], required: true)
                    }
                }
                
                // MARK : Integration Settings
                Group {
                    Toggle("Send my order data to provider", isOn: $option1)
                    Toggle("Auto Update my order statue", isOn: $option2)
                    Toggle("Update courier fees from server", isOn: $option3)
                }
                .tint(Color.accentColor)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Provider integration")
        .task {
            await loadData()
        }
        .willLoad(loading: loading)
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    update()
                }
                .disabled(saving || loading)
            }
        }
        .withPaywall(accessKey: .couriers, presentation: presentationMode)
    }
    
    func update() {
        guard let storeId = myUser?.storeId, validate() else { return }

        self.saving = true
        
        var apiInfo:[String:String] = [:]
        for (index, key) in Array(requiredValues.keys).enumerated() {
            let value = userInputs[index]
            apiInfo[key] = value
        }
        
        let data:[String : Any] = [
            "courierHandler" : selectedProvider,
            "apiData" : apiInfo,
            "sendDataToCompany": option1,
            "autoUpdateOrderStatue": option2,
            "updateCourierFee": option3
        ]
        
        Task {
            do {
                try await CouriersDao(storeId: storeId).update(id: courierId, hashMap: data)
                DispatchQueue.main.async {
                    ToastManager.shared.showToast(msg: "Settings updated", toastType: .success)
                    self.presentationMode.wrappedValue.dismiss()
                }
            } catch {
                ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
            }
            
            self.saving = false
        }
    }
    
    func validate() -> Bool {
        for input in userInputs {
            if input.isBlank {
                ToastManager.shared.showToast(msg: "Fill the required data", toastType: .error)
                return false
            }
        }
        
        return true
    }
    
    func updateRequiredValues() {
        requiredValues.removeAll()
        userInputs.removeAll()
        
        switch selectedProvider {
        case "QBEXPRESS" :
            requiredValues["email"] = "Dashboard Email Address"
            userInputs.append(apiData["email"] ?? "")

            requiredValues["password"] = "Dashboard Password"
            userInputs.append(apiData["password"] ?? "")
            break
        case "BOOSTA" :
            requiredValues["email"] = "Dashboard Email Address"
            userInputs.append(apiData["email"] ?? "")
            
            requiredValues["password"] = "Dashboard Password"
            userInputs.append(apiData["password"] ?? "")
            break
        default:
            userInputs.removeAll()
            requiredValues.removeAll()
            break
        }
    }
    
    func loadData() async {
        guard let storeId = myUser?.storeId else {
            return
        }
        
        self.loading = true
        
        if let result = try? await CouriersDao(storeId: storeId).getCourier(id: courierId) {
            DispatchQueue.main.async {
                self.selectedProvider = result.courierHandler ?? "None"
                self.apiData = result.apiData ?? [:]
                self.option1 = result.sendDataToCompany ?? true
                self.option2 = result.autoUpdateOrderStatue ?? true
                self.option3 = result.updateCourierFee ?? true
                self.loading = false
            }
        }
    }
}
