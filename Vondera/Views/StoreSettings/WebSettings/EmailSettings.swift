//
//  EmailSettings.swift
//  Vondera
//
//  Created by Shreif El Sayed on 25/03/2024.
//

import SwiftUI

let emailList = ["Gmail","Godaddy","GodaddyAsia","GodaddyEurope","hot.ee","Hotmail","iCloud","mail.ee","Yahoo","Yandex", "Zoho"]
struct EmailSettings: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var email = ""
    @State private var pass = ""
    @State private var provider = "Gmail"
    @State private var defaultMail = true
    
    
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showInfo = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Toggle("Use Vondera mail", isOn: $defaultMail)
                
                if showInfo {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Email Provider")
                            
                            Spacer()
                            
                            Picker("Pick Email Service", selection: $provider) {
                                ForEach(emailList, id: \.self) { email in
                                    Text(email)
                                        .tag(email)
                                }
                            }
                        }
                        
                        
                        FloatingTextField(title: "Email Address", text: $email, required: true)
                        
                        FloatingTextField(title: "Password", text: $pass, caption: "You may need to genrate an app password from your email provider (a diffrent password than your main one)", required: true)
                    }
                }
                
            }
            .padding()
        }
        .willLoad(loading: isLoading)
        .willProgress(saving: isSaving)
        .onChange(of: defaultMail) { _ in
            withAnimation {
                showInfo = !defaultMail
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    Task {
                        await save()
                    }
                }
                .disabled(isSaving || isLoading)
            }
        }
        .scrollIndicators(.hidden)
        .background(Color.background)
        .task {
            await fetchData()
        }
    }
    
    private func save() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        let data:[String : Any] = [
            "emailService.email" : email,
            "emailService.password" : pass,
            "emailService.useDefaultMail" : defaultMail,
            "emailService.service" : provider.lowercased()
        ]
        
        self.isSaving = true
        
        do {
            try await StoresDao().update(id: storeId, hashMap: data)
            DispatchQueue.main.async {
                ToastManager.shared.showToast(msg: "Email settings updated", toastType: .success)
                self.presentationMode.wrappedValue.dismiss()
            }
            
        } catch {
            ToastManager.shared.showToast(msg: error.localizedDescription.localize(), toastType: .error)
        }
        
        self.isSaving = false
    }
    
    private func fetchData() async {
        guard let storeId = UserInformation.shared.user?.storeId else {
            return
        }
        
        self.isLoading = true
        
        do {
            let result = try await StoresDao().getStore(uId: storeId)
            guard let result = result else { return }
            if let emailService = result.emailService {
                if let service = emailList.first(where: {$0.lowercased() == emailService.email ?? "Gmail"}) {
                    self.email = service
                }
                self.pass = emailService.password ?? ""
                self.defaultMail = emailService.useDefaultMail ?? true
                self.provider = emailService.service ?? ""
            }
        } catch {
            
        }
        
        self.isLoading = false
    }
}

#Preview {
    EmailSettings()
}
