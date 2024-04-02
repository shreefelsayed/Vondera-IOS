//
//  ChangeUsername.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/11/2023.
//

import SwiftUI
import AlertToast

struct CustomDomain: View {
    
    @State var domain = ""
    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:LocalizedStringKey?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            Section("Your custom domain") {
                FloatingTextField(title: "Custom Domain", text: $domain, caption: "This is your custom domain ex (vondera.app)", required: true, autoCapitalize: .never)
            }
           
            Section("Domain info") {
                Text("Add this to your custom DNS Record in your domain")
                
                HStack {
                    Text("Name")
                        .bold()
                    
                    Spacer()
                    
                    Text("@")
                }
                
                HStack {
                    Text("Type")
                        .bold()
                    
                    Spacer()
                    
                    Text("A")
                }
                
                HStack {
                    Text("Value")
                        .bold()
                    
                    Spacer()
                    
                    Text("76.76.21.21")
                }
                
                HStack {
                    Text("TTL")
                        .bold()
                    
                    Spacer()
                    
                    Text("600 Seconds")
                }
            }
            
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    handleUpdateClicked()
                }
                .disabled(saving)
            }
        }
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .task {
            if let customDomain = user.user?.store?.customDomain {
                domain = customDomain
            }
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        }
        .navigationTitle("Custom Domain")
    }
    
    func handleUpdateClicked() {
        guard check() else {
            return
        }
        
        if domain.isBlank {
            removeDomain()
        } else {
            connectDomain()
        }
    }
    
    func check() -> Bool {
        if domain.isBlank {
            return true
        }
        
        if !getDomain().isBlank && getDomain().contains(".") {
            return true
        }
        
        return false
    }
    
    func getDomain() -> String {
        return domain.lowercased().replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "/", with: "")
    }
    
    func handleRemoveResult(_ resultData:[String: Any]) {
        if let error = resultData["error"] as? String  {
            msg = error.localize()
            saving = false
            return
        }
        
        let serverMessage = resultData["msg"] as? String
        let success = resultData["success"] as? Bool
        
        if let success = success, success {
            UserInformation.shared.user?.store?.customDomain = ""
            presentationMode.wrappedValue.dismiss()
            msg = "Domain Disconnected"
        } else {
            msg = (serverMessage ?? "").localize()
        }
        
        saving = false
    }
    
    func handleConnectResult(_ resultData:[String: Any]) {
        if let error = resultData["error"] as? String  {
            msg = error.localize()
            saving = false
            return
        }
        
        let serverMessage = resultData["msg"] as? String
        let success = resultData["success"] as? Bool
        
        if let success = success, success {
            UserInformation.shared.user?.store?.customDomain = getDomain()
            presentationMode.wrappedValue.dismiss()
            msg = "Domain Connected"
        } else {
            msg = (serverMessage ?? "").localize()
        }
        
        saving = false
    }
    
    func removeDomain() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        let data = ["storeId": storeId]
        saving = true
        Task {
            if let result = try? await FirebaseFunctionCaller().callFunction(functionName: "domain-deleteDomainFromProject", data: data) {
                guard let resultData = result.data as? [String: Any] else {
                    saving = false
                    return
                }
                
                DispatchQueue.main.async {
                    handleConnectResult(resultData)
                }
            } else {
                msg = "Error Happened"
                saving = false
                return
            }
        }
    }
    
    func connectDomain() {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        let data = ["domain" : getDomain(), "storeId": storeId]
        saving = true
        
        Task {
            if let result = try? await FirebaseFunctionCaller().callFunction(functionName: "domain-addDomainToHosting", data: data) {
                guard let resultData = result.data as? [String: Any] else {
                    saving = false
                    return
                }
                DispatchQueue.main.async {
                    handleConnectResult(resultData)
                }
            } else {
                msg = "Error happened"
                saving = false
                return
            }
        }
    }
}

#Preview {
    CustomDomain()
}
