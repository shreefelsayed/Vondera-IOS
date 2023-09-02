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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.namePhonePad)
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
        .padding()
        .navigationTitle("Change Phone")
        .willProgress(saving: isSaving)
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        Task {
            self.myUser = await LocalInfo().getLocalUser()
            self.phoneNumber = myUser?.phone ?? ""
        }
    }
    
    func updateNumber() {
        Task {
            isSaving = true
            var data:[String: Any] = ["phone": phoneNumber]
            try! await UsersDao().update(id: myUser!.id, hash:data)
            myUser!.phone = phoneNumber
            await LocalInfo().saveUser(user: myUser)
            isSaving = false
            
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ChangePhoneView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePhoneView()
    }
}
