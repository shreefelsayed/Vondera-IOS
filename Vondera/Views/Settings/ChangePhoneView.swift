//
//  ChangePhoneView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct ChangePhoneView: View {
    @State var myUser:UserData?
    @State var phoneNumber:String = ""
    @State var isSaving = false
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        List {
            Section("Phone number") {
                FloatingTextField(title: "Phone Number", text: $phoneNumber, required: true, keyboard: .phonePad)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Update")
                    .bold()
                    .disabled(!phoneNumber.isPhoneNumber)
                    .foregroundStyle(phoneNumber.isPhoneNumber ? Color.accentColor : Color.gray)
                    .onTapGesture {
                        updateNumber()
                    }
            }
        }
        .navigationTitle("Change Phone")
        .willProgress(saving: isSaving)
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        self.myUser = UserInformation.shared.getUser()
        self.phoneNumber = myUser?.phone ?? ""
    }
    
    func updateNumber() {
        Task {
            if var myUser = myUser {
                isSaving = true
                let data:[String: Any] = ["phone": phoneNumber]
                try? await UsersDao().update(id: myUser.id, hash:data)
                myUser.phone = phoneNumber

                DispatchQueue.main.async { [myUser] in
                    UserInformation.shared.updateUser(myUser)
                    isSaving = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
        }
    }
}

#Preview {
    NavigationView {
        ChangePhoneView()
    }
}
