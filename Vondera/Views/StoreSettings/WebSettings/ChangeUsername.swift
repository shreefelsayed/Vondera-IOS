//
//  ChangeUsername.swift
//  Vondera
//
//  Created by Shreif El Sayed on 01/11/2023.
//

import SwiftUI
import AlertToast

struct ChangeUsername: View {
    
    @State var userName = ""
    @State var validName = false
    @State var validatingName = false
    
    @State var showDialog = false
    @ObservedObject var user = UserInformation.shared
    @State var saving = false
    @State var msg:LocalizedStringKey?
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        List {
            HStack {
                VStack (alignment: .leading) {
                    FloatingTextField(title: "Username", text: $userName, caption: "This will be your link, it should be english, no spaces, uniquie, no numbers", required: true, autoCapitalize: .never)
                        .onChange(of: userName, perform: { value in
                            validateUserName()
                        })
                    
                    Text("Your website url will be https://\(userName).vondera.shop/")
                        .font(.caption)
                }
                
                
                if validatingName {
                    ProgressView()
                } else if validName {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                }
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Update") {
                    if validName {
                        promotDialog()
                    }
                }
                .disabled(saving || !validName)
            }
        }
        .willProgress(saving: saving)
        .navigationBarBackButtonHidden(saving)
        .task {
            if let mId = user.user?.store?.merchantId {
                userName = mId
            }
        }
        .toast(isPresenting: Binding(value: $msg)) {
            AlertToast(displayMode: .banner(.pop), type: .regular, title: msg?.toString())
        }
        .confirmationDialog("WARNING", isPresented: $showDialog, titleVisibility: .visible, actions: {
            Button("Change Username") {
                update()
            }
            
            Button("Later", role: .cancel) {
                
            }
        }, message: {
            Text("Chaning your username will cause in changing your website link, are you sure you want to do this")
        })
        .navigationTitle("Change Username")
    }
    
    func promotDialog() {
        guard validName, userName.count > 2 else {
            msg = "Enter a valid username"
            return
        }
        
        self.showDialog = true
    }
    
    func update() {
        Task {
            if let id = UserInformation.shared.user?.storeId {
                saving = true
                let data = [
                    "merchantId" : userName.lowercased().replacingOccurrences(of: " ", with: ""),
                ]
                
                if let _ = try? await StoresDao().update(id: id, hashMap: data) {
                    // Call the firebase function
                    
                    // Call the firebase function
                    let data:[String:Any] = ["old" : user.user?.store?.merchantId ?? "", "new" : userName.lowercased().replacingOccurrences(of: " ", with: "")]
                    
                    _ = try await FirebaseFunctionCaller().callFunction(functionName: "sheets-userNameUpdated", data: data)
                    
                    DispatchQueue.main.async { [self] in
                        UserInformation.shared.user?.store?.merchantId = userName.lowercased().replacingOccurrences(of: " ", with: "")
                        presentationMode.wrappedValue.dismiss()
                        msg = "Updated"
                    }
                } else {
                    msg = "Error Happened"
                }
                
                saving = false
            }
        }
    }
    
    func validateUserName() {
        validName = false
        validatingName = true
        
        Task {
            if let valid = try? await StoresDao().validId(id: userName) {
                DispatchQueue.main.async {
                    self.validName = valid
                    self.validatingName = false
                }
            }
        }
    }
}

#Preview {
    ChangeUsername()
}
