//
//  NotificationsSettingsView.swift
//  Vondera
//
//  Created by Shreif El Sayed on 20/06/2023.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @ObservedObject var myUser = UserInformation.shared
    @State var newOrder:Bool = false
    @State var deletedOrder:Bool = false
    @State var stockFinished:Bool = false
    @State var newComplaint:Bool = false
    
    @State var isSaving = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List() {
            Section("Your notification settings") {
                Toggle("New Orders Notificaton", isOn: $newOrder)
                
                
                Toggle("Deleted Orders Notificaton", isOn: $deletedOrder)
                
                Toggle("Product Stock Finished Notificaton", isOn: $stockFinished)
                
                Toggle("New Order Complaint Notificaton", isOn: $newComplaint)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("Update")
                    .bold()
                    .foregroundStyle(Color.accentColor)
                    .onTapGesture {
                        update()
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
        Task {
            if let user = myUser.user {
                self.newOrder = user.notiSettings?.newOrder ?? true
                self.deletedOrder = user.notiSettings?.deletedOrder ?? true
                self.stockFinished = user.notiSettings?.stockFinished ?? true
                self.newComplaint = user.notiSettings?.newComplaint ?? true
            }
        }
    }
    
    func update() {
        Task {
            isSaving = true
            let data:NotiSettingPojo = NotiSettingPojo()
            data.newOrder = newOrder
            data.deletedOrder = deletedOrder
            data.stockFinished = stockFinished
            data.newComplaint = newComplaint
            
            if var myUser = myUser.user {
                let hash:[String: Any] = ["notiSettings": data.asDicitionry()]
                
                try? await UsersDao().update(id: myUser.id, hash:hash)
                myUser.notiSettings = data
                
                DispatchQueue.main.async { [myUser] in
                    UserInformation.shared.updateUser(myUser)
                    isSaving = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
        }
    }
}

struct NotificationsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsSettingsView()
    }
}
